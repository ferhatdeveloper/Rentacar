import 'package:equatable/equatable.dart';

enum VehicleStatus {
  available('Müsait', 0xFF0D9488),
  rented('Kirada', 0xFF2563EB),
  maintenance('Bakımda', 0xFFD97706),
  reserved('Rezerve', 0xFF7C3AED),
  outOfService('Servis Dışı', 0xFF6B7280);

  const VehicleStatus(this.label, this.colorValue);
  final String label;
  final int colorValue;
}

class Vehicle extends Equatable {
  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.category,
    required this.dailyPrice,
    required this.status,
    this.year,
    this.fuelType = 'Benzin',
    this.transmission = 'Otomatik',
    this.imageUrl,
    this.features = const [],
  });

  final String id;
  final String plateNumber;
  final String brand;
  final String model;
  final String category;
  final double dailyPrice;
  final VehicleStatus status;
  final int? year;
  final String fuelType;
  final String transmission;
  final String? imageUrl;
  final List<String> features;

  String get displayName => '$brand $model';
  String get priceLabel => '₺${dailyPrice.toStringAsFixed(0)}/gün';

  static const demoVehicles = [
    Vehicle(
      id: '1',
      plateNumber: '34 ABC 123',
      brand: 'BMW',
      model: '320i',
      category: 'Sedan',
      dailyPrice: 1850,
      status: VehicleStatus.available,
      year: 2024,
      transmission: 'Otomatik',
      features: ['GPS', 'Bluetooth', 'Deri Koltuk'],
    ),
    Vehicle(
      id: '2',
      plateNumber: '34 DEF 456',
      brand: 'Mercedes',
      model: 'GLC 200',
      category: 'SUV',
      dailyPrice: 2400,
      status: VehicleStatus.available,
      year: 2023,
      transmission: 'Otomatik',
      features: ['AWD', 'Panoramik Tavan'],
    ),
    Vehicle(
      id: '3',
      plateNumber: '34 GHI 789',
      brand: 'Renault',
      model: 'Clio',
      category: 'Ekonomi',
      dailyPrice: 650,
      status: VehicleStatus.rented,
      year: 2024,
      transmission: 'Manuel',
      features: ['Klima', 'Bluetooth'],
    ),
    Vehicle(
      id: '4',
      plateNumber: '34 JKL 012',
      brand: 'Audi',
      model: 'A6',
      category: 'Lüks',
      dailyPrice: 3200,
      status: VehicleStatus.available,
      year: 2024,
      transmission: 'Otomatik',
      features: ['Matrix LED', 'Massage Koltuk'],
    ),
  ];

  @override
  List<Object?> get props => [id];
}
