import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
    
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favoritos = <WordPair>[];
  var historial = <WordPair>[];
  var index = -1;

  GlobalKey? historialListKey;

  void getSiguiente(){
    if (index > 0){
      --index;
      current = historial.elementAt(index);
    }else{
      if(!historial.contains(current)){
        historial.insert(0, current);
        var animatedList = historialListKey?.currentState as AnimatedListState?;
        animatedList?.insertItem(0);
        
      }
      current = WordPair.random();
      index = -1;
    }
    notifyListeners();
  }
  void getAnterior() {
    if (index < historial.length-1) {
      if (index == -1) {
        historial.insert(0, current);
        var animatedList = historialListKey?.currentState as AnimatedListState?;
        animatedList?.insertItem(0);
        ++index;
      }
      ++index;
      current = historial.elementAt(index);
    }
    notifyListeners();
  }

  void removeFavorito([WordPair? idea]){
      favoritos.remove(idea);
      notifyListeners();
    }
/*
  void toggleFavorito() {
    if (favoritos.contains(current)){
      favoritos.remove(current);
    }else{
      favoritos.add(current);
    }
    notifyListeners();
  }
*/
  void toggleFavorito({WordPair? idea}) {
    idea = idea?? current;
    if (favoritos.contains(idea)){
      favoritos.remove(idea);
    }else{
      favoritos.add(idea);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritosPage();
        break;
      default:
        throw UnimplementedError('No hay un widget para: $selectedIndex');
    }
    return Scaffold(body: LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 450) {
        return Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favoritos'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
            SafeArea(
              child: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.favorite), label: 'Favoritos'),
                ],
                currentIndex: selectedIndex,
                onTap: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
          ],
        );
      }
    }));
  }
}


class BigCard extends StatelessWidget {
  final WordPair idea;

  const BigCard ({
    super.key,
    required this.idea
  });

  @override
  Widget build(BuildContext context){
    final tema = Theme.of(context);
    final TextStyle = tema.textTheme.displayMedium!.copyWith(
      color: tema.colorScheme.onPrimary,
    );

    return Card(
      color: tema.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(idea.asLowerCase , 
        style: TextStyle,
        semanticsLabel: "${idea.first} ${idea.second}",
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var appState = context.watch<MyAppState>();
    var idea = appState.current;
    IconData icon;
    if(appState.favoritos.contains(idea)){
      icon = Icons.favorite;
    }else{
      icon = Icons.favorite_outline;
    }

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: HistorialListView()),
              SizedBox(height: 20,),
            Text("Idea aleatoria"),
            SizedBox(height: 20,),
            BigCard(idea: appState.current),
            SizedBox(height: 20,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: (){appState.toggleFavorito();},
                  icon: Icon(icon), 
                  label: Text("Me gusta")),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: (){
                    appState.getAnterior();
                  }, 
                child: Text("Anterior")),
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: (){
                    appState.getSiguiente();
                  }, 
                child: Text("Siguiente")),
              ],
            ),
            Spacer(flex: 2,),
          ],
        ),
      );
  }
}

class FavoritosPage extends StatelessWidget{
  @override
  Widget  build(BuildContext context){
    var appState = context.watch<MyAppState>();

    if (appState.favoritos.isEmpty) {
      return Center(child: Text("Aun no hay favoritos"),);

    }

    

    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.all(20),
        child: Text("Se han elegido ${appState.favoritos.length} favoritos"),
        ),
        Expanded(
          child: GridView(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            childAspectRatio: 400/80,
          ),
          children: [
            for (var idea in appState.favoritos)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete_outline, semanticLabel: 'Eliminar'),
              color: Theme.of(context).colorScheme.primary,
              onPressed: (){
                appState.removeFavorito(idea);
              },
          ),
          title: Text(idea.asLowerCase),
          ),
        ],
      ),
        ),

      ],
    );
  }
}

class HistorialListView extends StatefulWidget {
  const HistorialListView({Key? key}) : super(key: key);

  @override
  State<HistorialListView> createState() => _HistorialListViewState();
}

class _HistorialListViewState extends State<HistorialListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.center,
    end: Alignment.bottomCenter,
  );
  
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historialListKey = _key;
    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.historial.length,
        itemBuilder: (context, index, animation){
          final idea = appState.historial[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: (){
                  appState.toggleFavorito(idea: idea);
                }, 
                icon: appState.favoritos.contains(idea)
                      ? Icon(Icons.favorite, size: 12, )
                      : SizedBox(), 
                label: Text(
                  idea.asLowerCase,
                  semanticsLabel: idea.asPascalCase,
                )
              )
            ), 
          );
        }
      ),
    );
  }
}
