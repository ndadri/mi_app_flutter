import 'package:flutter/material.dart';
import '../models/roles_permissions.dart';

class User {
  String name;
  String email;
  String password;
  bool active;
  UserRole role; // <--- nuevo campo

  User({
    required this.name,
    required this.email,
    required this.password,
    this.active = true,
    this.role = UserRole.user, // valor por defecto
  });
}

class AdminUsers extends StatefulWidget {
  const AdminUsers({Key? key}) : super(key: key);

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  final List<User> _users = [
    User(name: 'Juan Pérez', email: 'juan@mail.com', password: '123456', active: true, role: UserRole.admin),
    User(name: 'Ana López', email: 'ana@mail.com', password: 'abcdef', active: false, role: UserRole.assistant),
    User(name: 'Carlos Ruiz', email: 'carlos@mail.com', password: 'qwerty', active: true, role: UserRole.user),
  ];

  // Simula el usuario logueado (puedes cambiar el rol para probar)
  UserRole currentUserRole = UserRole.admin;
  String _search = '';

  void _showCreateUserDialog() {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String email = '';
    String password = '';
    UserRole role = UserRole.user;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear nuevo usuario'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                  onChanged: (value) => name = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Correo'),
                  validator: (value) => value == null || !value.contains('@') ? 'Correo inválido' : null,
                  onChanged: (value) => email = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                  onChanged: (value) => password = value,
                ),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: UserRole.values.map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.name),
                  )).toList(),
                  onChanged: (value) => role = value!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _users.add(User(name: name, email: email, password: password, role: role));
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario creado')),
                  );
                }
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(int index) {
    final _formKey = GlobalKey<FormState>();
    String name = _users[index].name;
    String email = _users[index].email;
    String password = _users[index].password;
    UserRole role = _users[index].role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar usuario'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                  onChanged: (value) => name = value,
                ),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  validator: (value) => value == null || !value.contains('@') ? 'Correo inválido' : null,
                  onChanged: (value) => email = value,
                ),
                TextFormField(
                  initialValue: password,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                  onChanged: (value) => password = value,
                ),
                DropdownButtonFormField<UserRole>(
                  value: role,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: UserRole.values.map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(r.name),
                  )).toList(),
                  onChanged: (value) => role = value!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _users[index].name = name;
                    _users[index].email = email;
                    _users[index].password = password;
                    _users[index].role = role;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario actualizado')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteUserDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar usuario'),
          content: Text('¿Desea eliminar o desactivar a ${_users[index].name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _users[index].active = false;
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario desactivado')),
                );
              },
              child: const Text('Desactivar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _users.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Usuario eliminado')),
                );
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _users.where((u) =>
      u.name.toLowerCase().contains(_search.toLowerCase()) ||
      u.email.toLowerCase().contains(_search.toLowerCase())
    ).toList();

    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 32, bottom: 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF7A45D1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'GESTIÓN USUARIOS',
                    style: TextStyle(
                      fontFamily: 'AntonSC',
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar Usuario',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _search = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final origIndex = _users.indexOf(user);
                    return Card(
                      color: user.active ? Colors.white : Colors.grey[200],
                      child: ListTile(
                        leading: Icon(user.active ? Icons.person : Icons.person_off, color: user.active ? Colors.green : Colors.red),
                        title: Text(user.name),
                        subtitle: Text('${user.email}\nRol: ${user.role.name}'),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditUserDialog(origIndex);
                            } else if (value == 'delete') {
                              _showDeleteUserDialog(origIndex);
                            }
                          },
                          itemBuilder: (context) {
                            final canEdit = AppPermissions.can(currentUserRole, 'edit_user');
                            final canDelete = AppPermissions.can(currentUserRole, 'delete_user');
                            return [
                              if (canEdit)
                                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                              if (canDelete)
                                const PopupMenuItem(value: 'delete', child: Text('Eliminar/Desactivar')),
                            ];
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Botón de crear usuario eliminado
      ],
    );
  }
}
