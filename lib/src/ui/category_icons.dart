import 'package:flutter/material.dart';

/// Maps an account's `iconKey` to a drawable icon.
///
/// Icons carry more of the interface than the words do here. Research on
/// low-literacy users is consistent on one point: a picture of the real thing
/// beats an abstract symbol. So groceries is a shopping basket rather than a
/// tag, gas is a flame rather than a meter, and mehmaan-nawazi is a cup of
/// chai — which is what hospitality actually looks like in a Pakistani home.
const Map<String, IconData> kCategoryIcons = <String, IconData>{
  // Where money sits
  'wallet': Icons.account_balance_wallet,
  'bank': Icons.account_balance,
  'savings': Icons.savings,

  // Coming in
  'salary': Icons.payments,
  'shop': Icons.storefront,
  'plus': Icons.add_circle,

  // Going out
  'groceries': Icons.shopping_basket,
  'vegetables': Icons.eco,
  'milk': Icons.local_drink,
  'bulb': Icons.lightbulb,
  'flame': Icons.local_fire_department,
  'water': Icons.water_drop,
  'home': Icons.home,
  'school': Icons.school,
  'medical': Icons.medical_services,
  'transport': Icons.directions_bus,
  'mobile': Icons.smartphone,
  'staff': Icons.people,
  'guests': Icons.emoji_food_beverage,
  'clothing': Icons.checkroom,
  'charity': Icons.volunteer_activism,
  'other': Icons.more_horiz,

  // Owed
  'debt': Icons.handshake,
  'committee': Icons.groups,

  // Bookkeeping
  'start': Icons.flag,
  'adjust': Icons.tune,
};

IconData iconForKey(String? iconKey) =>
    kCategoryIcons[iconKey] ?? Icons.circle_outlined;
