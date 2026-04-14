import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'models/cita.dart';
import 'models/cita_completa.dart';
import 'screens/nueva_cita_screen.dart';
import 'screens/detalle_cita_screen.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Estética Canina',
      home: const ServicioScreen(),
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

    final List<CitaCompleta> resultado =
        await DBHelper.getCitasCompletas(estatus: filtroSeleccionado);

    setState(() {
      citas = resultado;
      cargando = false;
    });
  }

  Color obtenerColorEstatus(String estatus) {
    switch (estatus.toLowerCase()) {
      case 'pendiente':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      case 'completado':
        return Colors.grey;
      default:
        return Colors.blueGrey;
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
    final List<Cita> listaCitas = await DBHelper.getCitas();
    final Cita citaSeleccionada =
        listaCitas.firstWhere((cita) => cita.id == citaId);

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleCitaScreen(cita: citaSeleccionada),
      ),
    );

    if (resultado == true) {
      cargarCitas();
    }
  }

  Widget construirFiltro() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: DropdownButtonFormField<String>(
        value: filtroSeleccionado,
        decoration: InputDecoration(
          labelText: 'Filtrar por estatus',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.filter_list),
        ),
        items: const [
          DropdownMenuItem(
            value: 'todos',
            child: Text('Todos'),
          ),
          DropdownMenuItem(
            value: 'pendiente',
            child: Text('Pendientes'),
          ),
          DropdownMenuItem(
            value: 'completado',
            child: Text('Completados'),
          ),
          DropdownMenuItem(
            value: 'cancelado',
            child: Text('Cancelados'),
          ),
        ],
        onChanged: (value) {
          setState(() {
            filtroSeleccionado = value!;
          });
          cargarCitas();
        },
      ),
    );
  }

  Widget construirLista() {
    if (cargando) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (citas.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No hay citas registradas',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: citas.length,
        itemBuilder: (context, index) {
          final cita = citas[index];
          final color = obtenerColorEstatus(cita.estatus);

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color,
                child: Icon(
                  obtenerIconoEstatus(cita.estatus),
                  color: Colors.white,
                ),
              ),
              title: Text('Mascota: ${cita.mascotaNombre}'),
              subtitle: Text(
                'Dueño: ${cita.duenoNombre}\nFecha: ${cita.fecha}\nHora: ${cita.hora}\nEstatus: ${cita.estatus}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => irADetalleCita(cita.id),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas Caninas'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          construirFiltro(),
          construirLista(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: irANuevaCita,
        child: const Icon(Icons.add),
      ),
    );
  }
}