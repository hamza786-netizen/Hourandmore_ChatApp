import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../services/listing_service.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final ListingService _listingService = ListingService.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minCapacityController = TextEditingController();

  List<Listing> _listings = [];
  List<Listing> _filteredListings = [];
  bool _isLoading = false;
  bool _isGridView = false;
  String _selectedStatus = 'all';
  bool _showFeaturedOnly = false;
  bool _showInsuranceOnly = false;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minCapacityController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final listings = await _listingService.getListings();
      setState(() {
        _listings = listings;
        _filteredListings = listings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load listings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredListings = _listings.where((listing) {
        // Search query filter
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          if (!listing.title.toLowerCase().contains(query) &&
              !listing.description.toLowerCase().contains(query) &&
              !listing.location.toLowerCase().contains(query)) {
            return false;
          }
        }

        // Location filter
        if (_locationController.text.isNotEmpty) {
          if (!listing.location.toLowerCase().contains(_locationController.text.toLowerCase())) {
            return false;
          }
        }

        // Price range filter
        if (_minPriceController.text.isNotEmpty) {
          final minPrice = double.tryParse(_minPriceController.text);
          if (minPrice != null) {
            final listingPrice = double.tryParse(listing.pricePerHour) ?? 0.0;
            if (listingPrice < minPrice) return false;
          }
        }

        if (_maxPriceController.text.isNotEmpty) {
          final maxPrice = double.tryParse(_maxPriceController.text);
          if (maxPrice != null) {
            final listingPrice = double.tryParse(listing.pricePerHour) ?? 0.0;
            if (listingPrice > maxPrice) return false;
          }
        }

        // Capacity filter
        if (_minCapacityController.text.isNotEmpty) {
          final minCapacity = int.tryParse(_minCapacityController.text);
          if (minCapacity != null && listing.capacity < minCapacity) {
            return false;
          }
        }

        // Status filter
        if (_selectedStatus != 'all' && listing.status != _selectedStatus) {
          return false;
        }

        // Featured filter - Disabled for now, kept for future use
        // if (_showFeaturedOnly && !listing.isFeatured) {
        //   return false;
        // }

        // Insurance filter - Disabled for now, kept for future use
        // if (_showInsuranceOnly && !listing.isInsurance) {
        //   return false;
        // }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minCapacityController.clear();
      _selectedStatus = 'all';
      // _showFeaturedOnly = false; // Disabled for now, kept for future use
      // _showInsuranceOnly = false; // Disabled for now, kept for future use
      _filteredListings = _listings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listings'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadListings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF6C63FF),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search listings...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => _applyFilters(),
            ),
          ),
          
          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredListings.length} listings found',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_filteredListings.length != _listings.length)
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ),
          
          // Listings
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredListings.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No listings found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _buildListView(), // Only list view for now, grid view disabled
          ),
        ],
      ),
    );
  }

  // Grid view method - disabled for now, kept for future use
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredListings.length,
      itemBuilder: (context, index) {
        final listing = _filteredListings[index];
        return _buildListingCard(listing);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredListings.length,
      itemBuilder: (context, index) {
        final listing = _filteredListings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildListingCard(listing, isList: true),
        );
      },
    );
  }

  Widget _buildListingCard(Listing listing, {bool isList = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        // onTap: () => _showListingDetails(listing), // Disabled for now, will be used in future
        borderRadius: BorderRadius.circular(12),
        child: isList ? _buildListCard(listing) : _buildGridCard(listing),
      ),
    );
  }

  Widget _buildGridCard(Listing listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: listing.images.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(listing.images.first.url),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: listing.images.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  )
                : Stack(
                    children: [
                      if (listing.isFeatured)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        
        // Content
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  listing.location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${listing.pricePerHour} SAR/hr',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C63FF),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.capacity}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        // Insurance icon removed - kept for future use if needed
                        // if (listing.isInsurance) ...[
                        //   const SizedBox(width: 8),
                        //   const Icon(Icons.security, size: 16, color: Colors.green),
                        // ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(Listing listing) {
    return Container(
      height: 140,
      child: Row(
        children: [
          // Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              image: listing.images.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(listing.images.first.url),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: listing.images.isEmpty
                ? const Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.grey,
                    ),
                  )
                : Stack(
                    children: [
                      if (listing.isFeatured)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title and Location
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  
                  // Description
                  Text(
                    listing.description,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  // Price and Capacity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${listing.pricePerHour} SAR/hr',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${listing.capacity}'),
                          // Insurance icon removed - kept for future use if needed
                          // if (listing.isInsurance) ...[
                          //   const SizedBox(width: 8),
                          //   const Icon(Icons.security, size: 16, color: Colors.green),
                          // ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Listings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),
              
              // Price Range
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Min Price',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Max Price',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Capacity
              TextField(
                controller: _minCapacityController,
                decoration: const InputDecoration(
                  labelText: 'Minimum Capacity',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Status
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.info),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value ?? 'all';
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Checkboxes - Disabled for now, kept for future use
              // CheckboxListTile(
              //   title: const Text('Featured Only'),
              //   value: _showFeaturedOnly,
              //   onChanged: (value) {
              //     setState(() {
              //       _showFeaturedOnly = value ?? false;
              //     });
              //   },
              // ),
              // CheckboxListTile(
              //   title: const Text('Insurance Only'),
              //   value: _showInsuranceOnly,
              //   onChanged: (value) {
              //     setState(() {
              //       _showInsuranceOnly = value ?? false;
              //     });
              //   },
              // ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearFilters();
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyFilters();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showListingDetails(Listing listing) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listing.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (listing.images.isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(listing.images.first.url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text('Description: ${listing.description}'),
              const SizedBox(height: 8),
              Text('Location: ${listing.location}'),
              const SizedBox(height: 8),
              Text('Price: ${listing.pricePerHour} SAR/hour'),
              if (listing.pricePerDay != null)
                Text('Price: ${listing.pricePerDay} SAR/day'),
              const SizedBox(height: 8),
              Text('Capacity: ${listing.capacity} ${listing.capacityType}'),
              const SizedBox(height: 8),
              Text('Status: ${listing.status}'),
              if (listing.isInsurance)
                const Text('Insurance: Included'),
              if (listing.isFeatured)
                const Text('Featured: Yes'),
              const SizedBox(height: 8),
              Text('Host: ${listing.host.name}'),
              Text('Contact: ${listing.host.phone}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement booking functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking functionality coming soon!'),
                ),
              );
            },
            child: const Text('Book Now'),
          ),
        ],
      ),
    );
  }
}
