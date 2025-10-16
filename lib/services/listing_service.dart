import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/listing.dart';

class ListingService {
  static final ListingService instance = ListingService._init();
  
  static const String _baseUrl = 'https://staging.hourandmore.sa/api/v1';
  static const String _listingsEndpoint = '/listings';
  
  ListingService._init();

  // Get all listings
  Future<List<Listing>> getListings() async {
    try {
      if (kDebugMode) {
        print('🌐 Fetching listings from API...');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl$_listingsEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('📡 API Response Status: ${response.statusCode}');
        print('📡 API Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('data') && data['data'] is List) {
          final List<dynamic> listingsJson = data['data'];
          final List<Listing> listings = listingsJson
              .map((json) => Listing.fromJson(json))
              .toList();
          
          if (kDebugMode) {
            print('✅ Successfully fetched ${listings.length} listings');
          }
          
          return listings;
        } else {
          if (kDebugMode) {
            print('❌ Invalid API response format');
          }
          throw Exception('Invalid API response format');
        }
      } else {
        if (kDebugMode) {
          print('❌ API Error: ${response.statusCode} - ${response.body}');
        }
        throw Exception('Failed to load listings: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching listings: $e');
      }
      rethrow;
    }
  }

  // Search listings with filters
  Future<List<Listing>> searchListings({
    String? query,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
    bool? isFeatured,
    bool? isInsurance,
    String? status,
  }) async {
    try {
      // Get all listings first (since API doesn't support query parameters)
      final allListings = await getListings();
      
      // Apply filters locally
      List<Listing> filteredListings = allListings;

      // Filter by search query
      if (query != null && query.isNotEmpty) {
        filteredListings = filteredListings.where((listing) {
          return listing.title.toLowerCase().contains(query.toLowerCase()) ||
                 listing.description.toLowerCase().contains(query.toLowerCase()) ||
                 listing.location.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }

      // Filter by location
      if (location != null && location.isNotEmpty) {
        filteredListings = filteredListings.where((listing) {
          return listing.location.toLowerCase().contains(location.toLowerCase());
        }).toList();
      }

      // Filter by price range
      if (minPrice != null) {
        filteredListings = filteredListings.where((listing) {
          final price = double.tryParse(listing.pricePerHour) ?? 0.0;
          return price >= minPrice;
        }).toList();
      }

      if (maxPrice != null) {
        filteredListings = filteredListings.where((listing) {
          final price = double.tryParse(listing.pricePerHour) ?? 0.0;
          return price <= maxPrice;
        }).toList();
      }

      // Filter by capacity
      if (minCapacity != null) {
        filteredListings = filteredListings.where((listing) {
          return listing.capacity >= minCapacity;
        }).toList();
      }

      // Filter by featured status
      if (isFeatured != null) {
        filteredListings = filteredListings.where((listing) {
          return listing.isFeatured == isFeatured;
        }).toList();
      }

      // Filter by insurance
      if (isInsurance != null) {
        filteredListings = filteredListings.where((listing) {
          return listing.isInsurance == isInsurance;
        }).toList();
      }

      // Filter by status
      if (status != null && status.isNotEmpty) {
        filteredListings = filteredListings.where((listing) {
          return listing.status.toLowerCase() == status.toLowerCase();
        }).toList();
      }

      if (kDebugMode) {
        print('🔍 Filtered ${filteredListings.length} listings from ${allListings.length} total');
      }

      return filteredListings;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error searching listings: $e');
      }
      rethrow;
    }
  }

  // Get featured listings
  Future<List<Listing>> getFeaturedListings() async {
    try {
      final allListings = await getListings();
      return allListings.where((listing) => listing.isFeatured).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching featured listings: $e');
      }
      rethrow;
    }
  }

  // Get listings by category
  Future<List<Listing>> getListingsByCategory(int categoryId) async {
    try {
      final allListings = await getListings();
      return allListings.where((listing) => listing.categoryId == categoryId).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching listings by category: $e');
      }
      rethrow;
    }
  }

  // Get listing by ID
  Future<Listing?> getListingById(int id) async {
    try {
      final allListings = await getListings();
      return allListings.firstWhere(
        (listing) => listing.id == id,
        orElse: () => throw Exception('Listing not found'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching listing by ID: $e');
      }
      return null;
    }
  }
}
