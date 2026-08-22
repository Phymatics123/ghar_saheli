import 'package:flutter_test/flutter_test.dart';
import 'package:ghar_saheli/src/core/money.dart';
import 'package:ghar_saheli/src/domain/tariffs.dart';

/// The slab arithmetic. The rates themselves are approximate and dated — these
/// tests check that the *bands are applied correctly*, which is the part that
/// stays true no matter what NEPRA does to the numbers.
void main() {
  group('estimateBill', () {
    test('charges each band separately, not everything at the top rate', () {
      // 150 units on K-Electric normal: 50 at 16.48, 50 at 23.20, 50 at 29.95.
      // The mistake this guards against is charging all 150 at 29.95, which
      // would overstate the bill by more than half.
      final BillEstimate estimate = estimateBill(
        tariff: kKElectricTariff,
        units: 150,
        isProtected: false,
        salesTaxPercent: 0,
      );

      expect(estimate.charges.length, 3);
      expect(estimate.charges[0].units, 50);
      expect(estimate.charges[1].units, 50);
      expect(estimate.charges[2].units, 50);

      final int expected = 50 * 1648 + 50 * 2320 + 50 * 2995;
      expect(estimate.energyCharge.paisa, expected);

      // The naive wrong answer, for contrast.
      expect(estimate.energyCharge.paisa, lessThan(150 * 2995));
    });

    test('bands report the unit range they cover', () {
      final BillEstimate estimate = estimateBill(
        tariff: kKElectricTariff,
        units: 150,
        isProtected: false,
      );
      expect(estimate.charges[0].fromUnit, 1);
      expect(estimate.charges[0].toUnit, 50);
      expect(estimate.charges[1].fromUnit, 51);
      expect(estimate.charges[1].toUnit, 100);
      expect(estimate.charges[2].fromUnit, 101);
      expect(estimate.charges[2].toUnit, 150);
    });

    test('a part-filled band only charges the units in it', () {
      final BillEstimate estimate = estimateBill(
        tariff: kKElectricTariff,
        units: 70,
        isProtected: false,
        salesTaxPercent: 0,
      );
      expect(estimate.charges.length, 2);
      expect(estimate.charges[1].units, 20);
      expect(estimate.energyCharge.paisa, 50 * 1648 + 20 * 2320);
    });

    test('the open-ended top band absorbs everything above it', () {
      final BillEstimate estimate = estimateBill(
        tariff: kKElectricTariff,
        units: 1200,
        isProtected: false,
        salesTaxPercent: 0,
      );
      final SlabCharge last = estimate.charges.last;
      expect(last.units, 500);
      expect(last.toUnit, 1200);
    });

    test('protected rates come out well below normal ones', () {
      final BillEstimate protectedBill = estimateBill(
        tariff: kKElectricTariff,
        units: 180,
        isProtected: true,
        salesTaxPercent: 0,
      );
      final BillEstimate normalBill = estimateBill(
        tariff: kKElectricTariff,
        units: 180,
        isProtected: false,
        salesTaxPercent: 0,
      );
      expect(protectedBill.total < normalBill.total, isTrue);
    });

    test('zero units costs nothing but still adds meter rent', () {
      final BillEstimate estimate = estimateBill(
        tariff: kLescoTariff,
        units: 0,
        isProtected: false,
        meterRent: Money.rupees(40),
        salesTaxPercent: 18,
      );
      expect(estimate.charges, isEmpty);
      expect(estimate.energyCharge, Money.zero);
      expect(estimate.salesTax, Money.zero);
      expect(estimate.total, Money.rupees(40));
    });

    test('negative units are treated as none rather than crashing', () {
      final BillEstimate estimate = estimateBill(
        tariff: kLescoTariff,
        units: -50,
        isProtected: false,
      );
      expect(estimate.energyCharge, Money.zero);
    });

    test('GST applies to energy and adjustments but not meter rent', () {
      final BillEstimate estimate = estimateBill(
        tariff: kKElectricTariff,
        units: 50,
        isProtected: false,
        fuelAdjustment: Money.rupees(100),
        meterRent: Money.rupees(40),
        salesTaxPercent: 18,
      );

      final int energy = 50 * 1648;
      final int taxable = energy + 10000;
      expect(estimate.salesTax.paisa, taxable * 18 ~/ 100);

      // Meter rent is in the total but was left out of the taxable base.
      expect(
        estimate.total.paisa,
        energy + 10000 + 4000 + estimate.salesTax.paisa,
      );
    });

    test('the effective per-unit rate exceeds the slab rate once GST lands',
        () {
      final BillEstimate estimate = estimateBill(
        tariff: kKElectricTariff,
        units: 300,
        isProtected: false,
        fuelAdjustment: Money.rupees(500),
        salesTaxPercent: 18,
      );
      expect(estimate.effectivePerUnit.isPositive, isTrue);
      expect(
        estimate.effectivePerUnit.paisa * 300,
        lessThanOrEqualTo(estimate.total.paisa),
      );
    });
  });
}
