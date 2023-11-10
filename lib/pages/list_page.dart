import 'dart:convert';
import 'dart:async';
import 'package:filters/pages/make_team.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});
  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _filteredItems = [];
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  bool _filterByMale = false;
  bool _filterByFemale = false;
  bool _filteredByAvailable = false;
  final List<Filter> _domainFilters = [
    Filter('Sales', false),
    Filter('Finance', false),
    Filter('Marketing', false),
    Filter('IT', false),
    Filter('Management', false),
    Filter('UI Designing', false),
    Filter('Business Development', false),
  ];

  final List<Map<String, dynamic>> _selectedUsers = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Load data when the widget is first created
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          if (_searchQuery.isNotEmpty || _filterByMale || _filteredByAvailable)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _clearFilters();
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _buildFilterbar(),
        ),
      ),
      body: Column(
        children: [
          if (_searchQuery.isEmpty &&
              _items.isNotEmpty &&
              !_filterByMale &&
              !_filteredByAvailable &&
              !_domainFilters.any((filter) => filter.value))
            Expanded(
              child: ListView.builder(
                itemCount: _calculateItemCount(),
                itemBuilder: (context, index) {
                  final dataIndex = index + _currentPage * _itemsPerPage;
                  return CardItem(
                    data: _items[dataIndex],
                    onAddToTeam: _addToTeam,
                    onRemoveFromTeam: _removeFromTeam,
                    selectedUsers: _selectedUsers,
                  );
                },
              ),
            )
          else if (_filteredItems.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  return CardItem(
                    data: _filteredItems[index],
                    onAddToTeam: _addToTeam,
                    onRemoveFromTeam: _removeFromTeam,
                    selectedUsers: _selectedUsers,
                  );
                },
              ),
            ),
          if (_searchQuery.isEmpty &&
              _items.isNotEmpty &&
              _currentPage * _itemsPerPage < _items.length)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentPage != 0)
                    ElevatedButton(
                      onPressed: () {
                        _prevPage();
                      },
                      child: const Text("Prev Page"),
                    ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      _nextPage();
                    },
                    child: const Text("Next Page"),
                  ),
                ],
              ),
            ),
          RawMaterialButton(
            onPressed: () {
              _showSelectedUsersDialog(context);
            },
            shape: const CircleBorder(),
            child: const Icon(
              Icons.group_add,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  void _addToTeam(Map<String, dynamic> user) {
    setState(() {
      final bool userWithSameDomainExists = _selectedUsers.any((selectedUsers) {
        return selectedUsers["domain"] == user["domain"];
      });
      if (userWithSameDomainExists) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("User of the same domain already exists"),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else if (!user['available']) {
        // Check if the user is not available (assuming 'available' is a boolean)
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("The user is not available"),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  ),
                ],
              );
            });
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  void _removeFromTeam(Map<String, dynamic> user) {
    setState(() {
      _selectedUsers.remove(user);
    });
  }

  void _showSelectedUsersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Selected Users"),
          content: SingleChildScrollView(
            child: Column(
              children: _selectedUsers.map((user) {
                return GestureDetector(
                  onTap: () {
                    _removeFromTeam(user);
                    setState(() {});
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user["avatar"]),
                            radius: 40,
                          ),
                          title: Text(
                              user["first_name"] + " " + user["last_name"]),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Gender: ${user["gender"]}"),
                              Text("${user["email"]}"),
                              Text("Domain: ${user["domain"]}"),
                              const SizedBox(height: 5),
                              const Text(
                                "Tap to remove",
                                style: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    color: Colors.black),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Final_Team(selectedUsers: _selectedUsers)));
              },
              child: const Text("Make Team"),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterButtons(
      String label, bool isActive, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: isActive
              ? ElevatedButton.styleFrom(backgroundColor: Colors.green)
              : null,
          child: Text(label),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  void _toggleFilterByGender() {
    setState(() {
      _filterByMale = !_filterByMale;
      _applyFilters();
    });
  }

  void _toggleFilterByFemale() {
    setState(() {
      _filterByFemale = !_filterByFemale;
      _applyFilters();
    });
  }

  void _toggleFilterByAvailability() {
    setState(() {
      _filteredByAvailable = !_filteredByAvailable;
      _applyFilters();
    });
  }

  Widget _buildFilterbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterButtons(
            "Male",
            _filterByMale,
            () => _toggleFilterByGender(),
          ),
          _buildFilterButtons(
            "Female",
            _filterByFemale,
            () => _toggleFilterByFemale(),
          ),
          _buildFilterButtons(
            "Available",
            _filteredByAvailable,
            () => _toggleFilterByAvailability(),
          ),
          for (final filter in _domainFilters)
            _buildFilterButtons(
              filter.name,
              filter.value,
              () => _toggleFilterByDomain(filter.name),
            ),
        ],
      ),
    );
  }

  void _toggleFilterByDomain(String domain) {
    setState(() {
      final filter = _domainFilters.firstWhere((f) => f.name == domain);
      filter.value = !filter.value;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredItems = _items.where((item) {
      final gender =
          item['gender'].toString().toLowerCase(); // Convert to lowercase
      if (_filterByMale && gender != 'male') {
        return false; // Keep "Male" when _filterByMale is true
      }
      if (_filterByFemale && gender != 'female') {
        return false;
      }
      if (_filteredByAvailable && !item['available']) {
        return false;
      }
      if (_domainFilters
          .any((filter) => filter.value && filter.name == item['domain'])) {
        return true;
      }
      return false;
    }).toList();
  }

  Future<void> _loadInitialData() async {
    final String response =
        await rootBundle.loadString('assets/heliverse_mock_data.json');
    final data = jsonDecode(response);

    List<Map<String, dynamic>> itemMaps = List<Map<String, dynamic>>.from(data);

    setState(() {
      _items = itemMaps;
    });
  }

  int _calculateItemCount() {
    final int totalItems = _items.length;
    final int remainingItems = totalItems - (_currentPage * _itemsPerPage);
    return remainingItems > _itemsPerPage ? _itemsPerPage : remainingItems;
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
  }

  void _prevPage() {
    setState(() {
      _currentPage--;
    });
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Search by Name"),
          content: TextField(
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _searchItems();
              },
              child: const Text("Search"),
            ),
          ],
        );
      },
    );
  }

  void _searchItems() {
    setState(() {
      _filteredItems = _items.where((item) {
        final name = item["first_name"].toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _filterByMale = false;
      _filterByFemale = false;
      _filteredByAvailable = false;
      for (var filter in _domainFilters) {
        filter.value = false;
      }
      _filteredItems.clear();
    });
  }
}

class CardItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onAddToTeam;
  final Function(Map<String, dynamic>) onRemoveFromTeam;
  final List<Map<String, dynamic>> selectedUsers;

  const CardItem({
    super.key,
    required this.data,
    required this.onAddToTeam,
    required this.onRemoveFromTeam,
    required this.selectedUsers,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUserSelected = selectedUsers.contains(data);

    return Card(
      margin: const EdgeInsets.only(
        top: 5,
        bottom: 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(data["avatar"]),
              radius: 40,
            ),
            title: Row(
              children: [
                Text(data["first_name"]),
                const Text(" "),
                Text(
                  data["last_name"],
                )
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Gender: ${data["gender"]}"),
                Text("Email: ${data["email"]}"),
                Text("Domain: ${data["domain"]}"),
              ],
            ),
            trailing: Text("Available: ${data["available"] ? 'Yes' : 'No'}"),
          ),
          ElevatedButton(
            onPressed: () {
              if (isUserSelected) {
                onRemoveFromTeam(data); // Remove the user from the team
              } else {
                onAddToTeam(data); // Add the user to the team
              }
            },
            child: Text(
              isUserSelected ? "Remove from Team" : "Add to Team",
            ),
          ),
        ],
      ),
    );
  }
}

class Filter {
  final String name;
  bool value;

  Filter(this.name, this.value);
}

void main() {
  runApp(const MaterialApp(
    home: ListPage(),
  ));
}
