import 'dart:convert';
import 'dart:io';

/// The Supabase project holding the activation codes.
///
/// **Both of these are safe to ship inside the APK.** Supabase's publishable
/// key is designed to be public; what stops it being useful to somebody who
/// unpacks the app is the database itself. The `license_keys` table has row
/// level security switched on with no policies granted, so this key cannot
/// read, list, insert or edit a single row by any route. The one thing it may
/// do is call `redeem_license`, which answers yes or no about a single code
/// and reveals nothing else — not whether a code exists, not how many are
/// left, not what any other code is.
///
/// The secret key from the same dashboard page is a different matter entirely
/// and must never appear in this file or any other part of the app.
const String kSupabaseUrl = 'https://kieutmltmveahrgxqyvp.supabase.co';
const String kSupabasePublishableKey =
    'sb_publishable_Fi_3Vlw6EUYRSKYoGcPccA_LMlKNKAD';

/// How an activation attempt turned out.
enum LicenseResult {
  /// The code was accepted and one of its redemptions has been spent.
  activated,

  /// The code does not exist, or every redemption has already been used.
  ///
  /// Deliberately one outcome rather than two. Telling somebody "that code is
  /// real but exhausted" hands them a way to test which codes exist.
  rejected,

  /// The phone could not reach the server at all.
  offline,

  /// Reached the server and it was unhappy. Worth separating from [offline]
  /// because the user can do nothing about this one but wait.
  serverError,
}

/// Checks an activation code, once, against the licence server.
///
/// This is the only moment in the app's life that a network call is required.
/// Once a code is accepted the answer is written to local storage and never
/// asked again — the ledger itself stays entirely offline, as it always has.
class LicenseService {
  const LicenseService();

  /// Codes are dealt in this shape: `ABCD-EFGH-JKLM-NPQR`.
  static const int codeLength = 19;

  /// Tidies what the user typed into what the server expects.
  ///
  /// People retype these from a WhatsApp message, so lowercase, stray spaces
  /// and missing dashes are all normal input rather than mistakes to punish.
  static String normalise(String input) {
    final String bare = input
        .toUpperCase()
        .replaceAll(RegExp('[^A-Z0-9]'), '');

    final StringBuffer out = StringBuffer();
    for (int i = 0; i < bare.length; i++) {
      if (i > 0 && i % 4 == 0) out.write('-');
      out.write(bare[i]);
    }
    return out.toString();
  }

  /// True once the text looks like a complete code. Used to keep the button
  /// disabled rather than letting somebody spend a request on half a code.
  static bool looksComplete(String input) =>
      normalise(input).length == codeLength;

  Future<LicenseResult> redeem(String code) async {
    final Uri? uri = Uri.tryParse('$kSupabaseUrl/rest/v1/rpc/redeem_license');
    if (uri == null || uri.scheme != 'https') {
      return LicenseResult.serverError;
    }

    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);

    try {
      final HttpClientRequest request = await client.postUrl(uri);
      request.headers.set('apikey', kSupabasePublishableKey);
      request.headers.set('Authorization', 'Bearer $kSupabasePublishableKey');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(<String, String>{
        'input_code': normalise(code),
      }));

      final HttpClientResponse response = await request.close();
      final String body =
          (await response.transform(utf8.decoder).join()).trim();

      if (response.statusCode != 200) return LicenseResult.serverError;

      // The function returns a bare JSON boolean.
      return body == 'true'
          ? LicenseResult.activated
          : LicenseResult.rejected;
    } on SocketException {
      return LicenseResult.offline;
    } on HttpException {
      return LicenseResult.offline;
    } on FormatException {
      return LicenseResult.serverError;
    } finally {
      client.close();
    }
  }
}
