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

    final citaSeleccionada = lista.firstWhere((cita) => cita.id == citaId);

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filtros.map((filtro) {
          final bool seleccionado = filtroSeleccionado == filtro;

          String texto;
          switch (filtro) {
            case 'pendiente':
              texto = 'Pendientes';
              break;
            case 'completado':
              texto = 'Completados';
              break;
            case 'cancelado':
              texto = 'Cancelados';
              break;
            default:
              texto = 'Todos';
          }

          return ChoiceChip(
            label: Text(
              texto,
              style: TextStyle(
                color: seleccionado ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: seleccionado,
            backgroundColor: Colors.white,
            selectedColor: Colors.orange.shade400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: seleccionado
                    ? Colors.orange.shade400
                    : Colors.orange.shade100,
              ),
            ),
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

  Widget construirResumenSuperior() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade300,
              Colors.deepOrange.shade300,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade100,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pets,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de citas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Administra tus servicios caninos de forma rápida',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget construirTarjetaCita(CitaCompleta cita) {
    final color = obtenerColorEstatus(cita.estatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: color,
              child: Icon(
                obtenerIconoEstatus(cita.estatus),
                color: Colors.white,
              ),
            ),
            title: Text(
              cita.mascotaNombre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Dueño: ${cita.duenoNombre}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            trailing: const Icon(Icons.expand_more_rounded),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    construirFilaDetalle(
                      Icons.calendar_month,
                      'Fecha',
                      cita.fecha,
                    ),
                    const SizedBox(height: 10),
                    construirFilaDetalle(
                      Icons.access_time,
                      'Hora',
                      cita.hora,
                    ),
                    const SizedBox(height: 10),
                    construirFilaDetalle(
                      Icons.flag,
                      'Estatus',
                      cita.estatus,
                      valorColor: color,
                      boldValue: true,
                    ),
                    const SizedBox(height: 10),
                    construirFilaDetalle(
                      Icons.content_cut,
                      'Servicio(s)',
                      cita.servicios,
                    ),
                    const SizedBox(height: 10),
                    construirFilaDetalle(
                      Icons.attach_money,
                      'Total',
                      '\$${cita.total.toStringAsFixed(2)}',
                      boldValue: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => irADetalleCita(cita.id),
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar cita'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade400,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget construirFilaDetalle(
    IconData icono,
    String titulo,
    String valor, {
    Color? valorColor,
    bool boldValue = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 18, color: Colors.orange.shade500),
        const SizedBox(width: 8),
        Text(
          '$titulo: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            valor,
            style: TextStyle(
              color: valorColor,
              fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget construirDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade300,
                  Colors.deepOrange.shade300,
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.pets,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 10),
                Text(
                  'Estética Canina',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Menú principal',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
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
            leading: const Icon(Icons.logout, color: Colors.red),
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
      backgroundColor: Colors.orange.shade50,
      drawer: construirDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: irANuevaCita,
        backgroundColor: Colors.orange.shade400,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva cita'),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 120,
                  backgroundColor: Colors.orange.shade400,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: const Text(
                      'Pet Service',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade300,
                            Colors.deepOrange.shade300,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: construirResumenSuperior(),
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
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return construirTarjetaCita(citas[index]);
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