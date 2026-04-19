import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'models/cita.dart';
import 'models/cita_completa.dart';
import 'screens/login_screen.dart';
import 'screens/nueva_cita_screen.dart';
import 'screens/detalle_cita_screen.dart';
import 'screens/calendario_screen.dart';
import 'screens/categoria_screen.dart';
import 'screens/servicio_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estética Canina',
      home: LoginScreen(),
    );
  }
}

class ListaCitasScreen extends StatefulWidget {
  const ListaCitasScreen({super.key});

  @override
  State<ListaCitasScreen> createState() => _ListaCitasScreenState();
}

class _ListaCitasScreenState extends State<ListaCitasScreen> {
  List<CitaCompleta> citas = [];
  bool cargando = true;
  String filtroSeleccionado = 'todos';

  @override
  void initState() {
    super.initState();
    cargarCitas();
  }

  Future<void> cargarCitas() async {
    setState(() {
      cargando = true;
    });

    final resultado =
        await DBHelper.getCitasCompletas(estatus: filtroSeleccionado);

    setState(() {
      citas = resultado;
      cargando = false;
    });
  }

  Color obtenerColorEstatus(String estatus) {
    switch (estatus.toLowerCase()) {
      case 'completado':
        return Colors.green;
      case 'pendiente':
      case 'en proceso':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData obtenerIconoEstatus(String estatus) {
    switch (estatus.toLowerCase()) {
      case 'pendiente':
        return Icons.access_time;
      case 'cancelado':
        return Icons.cancel;
      case 'completado':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Future<void> irANuevaCita() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NuevaCitaScreen(),
      ),
    );

    if (resultado == true) {
      cargarCitas();
    }
  }

  Future<void> irADetalleCita(int citaId) async {
    final lista = await DBHelper.getCitas();

    final citaSeleccionada =
        lista.firstWhere((cita) => cita.id == citaId);

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetalleCitaScreen(cita: citaSeleccionada),
      ),
    );

    if (resultado == true) {
      cargarCitas();
    }
  }

  Future<void> abrirPantalla(Widget pantalla) async {
    Navigator.pop(context);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => pantalla,
      ),
    );

    cargarCitas();
  }

  void cerrarSesion() {
    Navigator.pop(context);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget construirFiltro() {
    final filtros = [
      'todos',
      'pendiente',
      'completado',
      'cancelado',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: filtros.map((filtro) {
          return ChoiceChip(
            label: Text(
              filtro == 'todos'
                  ? 'Todos'
                  : filtro == 'pendiente'
                      ? 'Pendientes'
                      : filtro == 'completado'
                          ? 'Completados'
                          : 'Cancelados',
            ),
            selected: filtroSeleccionado == filtro,
            selectedColor: Colors.orange.shade300,
            onSelected: (selected) {
              setState(() {
                filtroSeleccionado = filtro;
              });

              cargarCitas();
            },
          );
        }).toList(),
      ),
    );
  }

  Widget construirTarjetaCita(CitaCompleta cita) {
    final color = obtenerColorEstatus(cita.estatus);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            obtenerIconoEstatus(cita.estatus),
            color: Colors.white,
          ),
        ),
        title: Text('Mascota: ${cita.mascotaNombre}'),
        subtitle: Text('Dueño: ${cita.duenoNombre}'),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Fecha: ${cita.fecha}'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Hora: ${cita.hora}'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Estatus: ${cita.estatus}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Servicio(s): ${cita.servicios}'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Total: \$${cita.total.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => irADetalleCita(cita.id),
              icon: const Icon(Icons.edit),
              label: const Text('Editar cita'),
            ),
          ),
        ],
      ),
    );
  }

  Widget construirDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orange.shade400,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.pets, size: 48, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  'Estética Canina',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'Menú principal',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Citas'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendario'),
            onTap: () => abrirPantalla(const CalendarioScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorías'),
            onTap: () => abrirPantalla(const CategoriaScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.design_services),
            title: const Text('Servicios'),
            onTap: () => abrirPantalla(const ServicioScreen()),
          ),
          const Divider(),
          ListTile(
            leading:
                const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión'),
            onTap: cerrarSesion,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: construirDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: irANuevaCita,
        child: const Icon(Icons.add),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 100,
                  title: const Text('Citas Caninas'),
                  centerTitle: true,
                ),
                SliverToBoxAdapter(
                  child: construirFiltro(),
                ),
                citas.isEmpty
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No hay citas registradas',
                            style:
                                TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate:
                            SliverChildBuilderDelegate(
                          (context, index) {
                            return construirTarjetaCita(
                                citas[index]);
                          },
                          childCount: citas.length,
                        ),
                      ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 90),
                ),
              ],
            ),
    );
  }
}