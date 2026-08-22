import '../core/money.dart';

/// One band of a slab tariff.
class TariffSlab {
  const TariffSlab({
    required this.upToUnits,
    required this.paisaPerUnit,
  });

  /// Inclusive upper bound of this band. `null` means "everything above".
  final int? upToUnits;

  /// Rate in paisa, so Rs 16.48/unit is 1648.
  final int paisaPerUnit;
}

/// A named electricity tariff.
///
/// **These rates are approximate and dated.** NEPRA revises them, sometimes
/// several times a year, and the bands below were taken from published 2026
/// figures rather than from a live source this app can check. They are here to
/// make an estimate useful, not to be authoritative — the calculator says so
/// on screen, and every screen that shows a total calls it an estimate.
///
/// When they go stale, this list is the only thing that needs editing.
class ElectricityTariff {
  const ElectricityTariff({
    required this.id,
    required this.name,
    required this.nameUr,
    required this.protectedSlabs,
    required this.normalSlabs,
  });

  final String id;
  final String name;
  final String nameUr;

  /// For households that have stayed under 200 units for six months. A
  /// genuinely large discount, and the reason the protected category exists.
  final List<TariffSlab> protectedSlabs;

  final List<TariffSlab> normalSlabs;

  List<TariffSlab> slabsFor({required bool isProtected}) =>
      isProtected ? protectedSlabs : normalSlabs;
}

/// Rates as published in 2026. See the warning on [ElectricityTariff].
const ElectricityTariff kLescoTariff = ElectricityTariff(
  id: 'lesco',
  name: 'LESCO',
  nameUr: 'لیسکو',
  protectedSlabs: <TariffSlab>[
    TariffSlab(upToUnits: 50, paisaPerUnit: 395),
    TariffSlab(upToUnits: 100, paisaPerUnit: 1054),
    TariffSlab(upToUnits: 200, paisaPerUnit: 1301),
    TariffSlab(upToUnits: null, paisaPerUnit: 2320),
  ],
  normalSlabs: <TariffSlab>[
    TariffSlab(upToUnits: 100, paisaPerUnit: 2320),
    TariffSlab(upToUnits: 200, paisaPerUnit: 2995),
    TariffSlab(upToUnits: 300, paisaPerUnit: 3499),
    TariffSlab(upToUnits: 400, paisaPerUnit: 3914),
    TariffSlab(upToUnits: 500, paisaPerUnit: 4137),
    TariffSlab(upToUnits: 600, paisaPerUnit: 4262),
    TariffSlab(upToUnits: 700, paisaPerUnit: 4360),
    TariffSlab(upToUnits: null, paisaPerUnit: 4769),
  ],
);

const ElectricityTariff kKElectricTariff = ElectricityTariff(
  id: 'kelectric',
  name: 'K-Electric',
  nameUr: 'کے الیکٹرک',
  protectedSlabs: <TariffSlab>[
    TariffSlab(upToUnits: 100, paisaPerUnit: 1054),
    TariffSlab(upToUnits: 200, paisaPerUnit: 1301),
    TariffSlab(upToUnits: null, paisaPerUnit: 2320),
  ],
  normalSlabs: <TariffSlab>[
    TariffSlab(upToUnits: 50, paisaPerUnit: 1648),
    TariffSlab(upToUnits: 100, paisaPerUnit: 2320),
    TariffSlab(upToUnits: 200, paisaPerUnit: 2995),
    TariffSlab(upToUnits: 300, paisaPerUnit: 3499),
    TariffSlab(upToUnits: 400, paisaPerUnit: 3914),
    TariffSlab(upToUnits: 500, paisaPerUnit: 4137),
    TariffSlab(upToUnits: 600, paisaPerUnit: 4262),
    TariffSlab(upToUnits: 700, paisaPerUnit: 4360),
    TariffSlab(upToUnits: null, paisaPerUnit: 3524),
  ],
);

const List<ElectricityTariff> kElectricityTariffs = <ElectricityTariff>[
  kLescoTariff,
  kKElectricTariff,
];

/// One band's contribution to a bill, kept so the working can be shown.
class SlabCharge {
  const SlabCharge({
    required this.fromUnit,
    required this.toUnit,
    required this.units,
    required this.paisaPerUnit,
    required this.amount,
  });

  final int fromUnit;
  final int toUnit;
  final int units;
  final int paisaPerUnit;
  final Money amount;

  double get rupeesPerUnit => paisaPerUnit / 100;
}

/// An estimated electricity bill, broken into the lines a real bill has.
///
/// The extras are separate on purpose. A Pakistani bill is not units times a
/// rate — fuel cost adjustment, quarterly adjustment, GST and meter rent are
/// added on top, they move independently of the slabs, and folding them into a
/// blended per-unit figure is exactly how estimates end up wrong by thousands.
/// They are entered by the user because they are printed on last month's bill
/// and cannot be derived.
class BillEstimate {
  const BillEstimate({
    required this.units,
    required this.charges,
    required this.energyCharge,
    required this.fuelAdjustment,
    required this.quarterlyAdjustment,
    required this.meterRent,
    required this.salesTaxPercent,
    required this.salesTax,
    required this.total,
  });

  final int units;
  final List<SlabCharge> charges;

  /// Units times slab rates, before anything is added.
  final Money energyCharge;

  final Money fuelAdjustment;
  final Money quarterlyAdjustment;
  final Money meterRent;
  final double salesTaxPercent;
  final Money salesTax;
  final Money total;

  /// What the bill works out to per unit once everything is included. Useful
  /// as a reality check against the rate people think they are paying.
  Money get effectivePerUnit =>
      units == 0 ? Money.zero : Money(total.paisa ~/ units);
}

/// Applies a slab tariff to a number of units.
///
/// Bands are cumulative: only the units falling inside a band are charged at
/// that band's rate. This is how the published tariffs work for domestic
/// consumers, and it is not the same as finding the band a total lands in and
/// charging every unit at that rate — a mistake that overstates a large bill
/// badly.
BillEstimate estimateBill({
  required ElectricityTariff tariff,
  required int units,
  required bool isProtected,
  Money fuelAdjustment = Money.zero,
  Money quarterlyAdjustment = Money.zero,
  Money meterRent = Money.zero,
  double salesTaxPercent = 18,
}) {
  final List<TariffSlab> slabs = tariff.slabsFor(isProtected: isProtected);
  final List<SlabCharge> charges = <SlabCharge>[];

  int remaining = units < 0 ? 0 : units;
  int consumedSoFar = 0;
  int energyPaisa = 0;

  for (final TariffSlab slab in slabs) {
    if (remaining <= 0) break;

    final int bandCapacity = slab.upToUnits == null
        ? remaining
        : slab.upToUnits! - consumedSoFar;
    if (bandCapacity <= 0) continue;

    final int unitsHere = remaining < bandCapacity ? remaining : bandCapacity;
    final int amount = unitsHere * slab.paisaPerUnit;

    charges.add(
      SlabCharge(
        fromUnit: consumedSoFar + 1,
        toUnit: consumedSoFar + unitsHere,
        units: unitsHere,
        paisaPerUnit: slab.paisaPerUnit,
        amount: Money(amount),
      ),
    );

    energyPaisa += amount;
    consumedSoFar += unitsHere;
    remaining -= unitsHere;
  }

  final Money energy = Money(energyPaisa);

  // GST applies to the energy charge and the adjustments, not to meter rent.
  final int taxableBase =
      energy.paisa + fuelAdjustment.paisa + quarterlyAdjustment.paisa;
  final Money salesTax = Money(taxableBase * salesTaxPercent ~/ 100);

  final Money total = energy +
      fuelAdjustment +
      quarterlyAdjustment +
      meterRent +
      salesTax;

  return BillEstimate(
    units: units,
    charges: charges,
    energyCharge: energy,
    fuelAdjustment: fuelAdjustment,
    quarterlyAdjustment: quarterlyAdjustment,
    meterRent: meterRent,
    salesTaxPercent: salesTaxPercent,
    salesTax: salesTax,
    total: total,
  );
}
