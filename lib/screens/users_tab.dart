import 'package:flutter/material.dart';
import '../services/user_service.dart';

// Onglet affichant la liste des utilisateurs (pour l'admin)
class UsersTab extends StatefulWidget {
  @override
  _UsersTabState createState() => _UsersTabState();
}

// State de l'onglet utilisateurs
class _UsersTabState extends State<UsersTab> {
  late Future<List<dynamic>> _usersFuture;
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  String _searchQuery = '';
  // Filtres sélectionnés
  String? _selectedRole;
  String? _selectedDepartment;

  // Options de rôles et départements
  final List<String> _roles = ['staff', 'admin'];
  final List<String> _departments = [
    'Nettoyage', 'Réception', 'Maintenance', 'Sécurité',
    'Restauration', 'Cuisine', 'Blanchisserie', 'Spa', 'Informatique', 'Direction'
  ];

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchAndSetUsers();
  }

  Future<List<dynamic>> _fetchAndSetUsers() async {
    try {
      final users = await UserService.getUsers();
      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = users;
        });
      }
      return users;
    } catch (e) {
      // Gérer l'erreur, par exemple en affichant un message
      print("Erreur lors de la récupération des utilisateurs: $e");
      return []; // Retourner une liste vide en cas d'erreur
    }
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _fetchAndSetUsers();
    });
  }

  // Supprime un utilisateur
  void _deleteUser(String id) async {
    await UserService.deleteUser(id, context);
    _refreshUsers();
  }

  // Affiche le formulaire d'ajout/modification d'utilisateur
  void _showUserForm({Map<String, dynamic>? user}) async {
    final result = await showDialog(
      context: context,
      builder: (context) => UserFormDialog(user: user),
    );
    if (result == true) _refreshUsers();
  }

  // Filtre la liste selon la recherche
  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  // Applique les filtres sélectionnés
  void _applyFilters() {
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final nameMatch = (u['name'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
        final roleMatch = _selectedRole == null || u['role'] == _selectedRole;
        final departmentMatch = _selectedDepartment == null || (u['departments'] != null && (u['departments'] as List).contains(_selectedDepartment));
        return nameMatch && roleMatch && departmentMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final maxWidth = isWide ? 800.0 : double.infinity;
    final horizontalPadding = isWide ? 0.0 : 8.0;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Rechercher un utilisateur',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: _filterUsers,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.work, size: 16, color: Colors.grey[600]),
                                        SizedBox(width: 4),
                                        Text(
                                          'Rôle',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedRole,
                                        hint: Text('Tous les rôles', style: TextStyle(color: Colors.grey[600])),
                                        isExpanded: true,
                                        items: [null, ..._roles].map((role) {
                                          return DropdownMenuItem<String>(
                                            value: role,
                                            child: Text(role == 'admin' ? 'Admin' : 'Staff', style: TextStyle(color: Colors.grey[800])),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() => _selectedRole = val);
                                          _applyFilters();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.business, size: 16, color: Colors.grey[600]),
                                        SizedBox(width: 4),
                                        Text(
                                          'Département',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedDepartment,
                                        hint: Text('Tous les départements', style: TextStyle(color: Colors.grey[600])),
                                        isExpanded: true,
                                        items: [null, ..._departments].map((dept) {
                                          return DropdownMenuItem<String>(
                                            value: dept,
                                            child: Text(dept ?? 'Tous', style: TextStyle(color: Colors.grey[800])),
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          setState(() => _selectedDepartment = val);
                                          _applyFilters();
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _usersFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || _filteredUsers.isEmpty) {
                        return Center(child: Text('Aucun utilisateur trouvé.'));
                      }
                      return ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.blue.shade100,
                                        child: Text(
                                          (user['name'] ?? '')[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['name'] ?? '',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              user['email'] ?? '',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.work, size: 16, color: Colors.blue.shade700),
                                            SizedBox(width: 4),
                                            Text(
                                              user['role'] ?? '',
                                              style: TextStyle(
                                                color: Colors.blue.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.business, size: 16, color: Colors.green.shade700),
                                            SizedBox(width: 4),
                                            Text(
                                              (user['departments'] != null)
                                                  ? (user['departments'] as List).join(', ')
                                                  : '',
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: Icon(Icons.edit, size: 20),
                                        label: Text('Modifier'),
                                        onPressed: () => _showUserForm(user: user),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue.shade700,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      TextButton.icon(
                                        icon: Icon(Icons.delete, size: 20),
                                        label: Text('Supprimer'),
                                        onPressed: () => _deleteUser(user['_id']),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _showUserForm(),
                child: Icon(Icons.add),
                backgroundColor: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserFormDialog extends StatefulWidget {
  final Map<String, dynamic>? user;
  UserFormDialog({this.user});

  @override
  _UserFormDialogState createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String _role = 'staff';
  List<String> _selectedDepartments = [];
  final List<String> _roles = ['staff', 'admin'];
  final List<String> _departments = [
    'Nettoyage', 'Réception', 'Maintenance', 'Sécurité',
    'Restauration', 'Cuisine', 'Blanchisserie', 'Spa', 'Informatique', 'Direction'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?['name'] ?? '');
    _emailController = TextEditingController(text: widget.user?['email'] ?? '');
    _passwordController = TextEditingController();
    _role = widget.user?['role'] ?? 'staff';
    if (widget.user?['departments'] != null) {
      if (widget.user!['departments'] is List) {
        _selectedDepartments = List<String>.from(widget.user!['departments']);
      } else if (widget.user!['departments'] is String) {
        _selectedDepartments = [widget.user!['departments']];
      } else {
        _selectedDepartments = [];
      }
    } else if (widget.user?['department'] != null) {
      _selectedDepartments = [widget.user!['department']];
    } else {
      _selectedDepartments = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final Map<String, dynamic> userData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'role': _role,
    };
    if (_role == 'staff') {
      userData['departments'] = List<String>.from(_selectedDepartments);
    }
    String? adminName = await UserService.getConnectedUserName();
    if (widget.user == null) {
      userData['password'] = _passwordController.text;
      userData['ajoutePar'] = adminName;
      final exists = await UserService.checkEmailExists(_emailController.text);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cet email existe déjà.')));
        return;
      }
      await UserService.createUser(userData, context);
    } else {
      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      }
      userData['modifiePar'] = adminName;
      await UserService.updateUser(widget.user!['_id'], userData, context);
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.user == null ? 'Ajouter un utilisateur' : 'Modifier utilisateur',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
      content: Container(
        width: 420,
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email requis';
                    if (!v.contains('@') || !v.contains('.')) return 'Email invalide';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (v) {
                    if (widget.user == null && (v == null || v.isEmpty)) return 'Mot de passe requis';
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _role,
                  items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r == 'admin' ? 'Admin' : 'Staff'))).toList(),
                  onChanged: (v) => setState(() => _role = v!),
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                SizedBox(height: 16),
                if (_role == 'staff')
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Icon(Icons.business, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Text(
                                'Départements',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1),
                        Container(
                          constraints: BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _departments.length,
                            itemBuilder: (context, index) {
                              final department = _departments[index];
                              return CheckboxListTile(
                                title: Text(department),
                                value: _selectedDepartments.contains(department),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedDepartments.add(department);
                                    } else {
                                      _selectedDepartments.remove(department);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey[600],
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget.user == null ? 'Ajouter' : 'Modifier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
} 