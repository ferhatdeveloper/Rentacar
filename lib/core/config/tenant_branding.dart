import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TenantBranding extends Equatable {
  const TenantBranding({
    required this.tenantId,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.primaryColor = const Color(0xFF0B1F3A),
    this.accentColor = const Color(0xFFE8A317),
    this.heroTitle = 'Yolculuğunuza Premium Başlayın',
    this.heroSubtitle =
        'Geniş filomuzdan size en uygun aracı seçin, dakikalar içinde kirala.',
    this.heroImageUrl,
    this.contactPhone,
    this.whatsappNumber,
  });

  final String tenantId;
  final String name;
  final String slug;
  final String? logoUrl;
  final Color primaryColor;
  final Color accentColor;
  final String heroTitle;
  final String heroSubtitle;
  final String? heroImageUrl;
  final String? contactPhone;
  final String? whatsappNumber;

  static const demo = TenantBranding(
    tenantId: 'demo',
    name: 'Premium Rent',
    slug: 'premium-rent',
    contactPhone: '+90 212 555 0100',
    whatsappNumber: '905555010000',
  );

  @override
  List<Object?> get props => [tenantId, slug];
}
