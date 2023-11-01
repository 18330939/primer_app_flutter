import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
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

  void getSiguiente(){
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorito() {
    if (favoritos.contains(current)){
      favoritos.remove(current);
    }else{
      favoritos.add(current);
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
  Widget build(BuildContext context){
    Widget page;
    switch (selectedIndex) {
      case 0: page = GeneratorPage(); break;
      case 1: page = Placeholder(); break; 
      default:
        throw UnimplementedError('No hay un widget para: $selectedIndex');
    }  
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home), 
                  label: Text("Inicio")),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite), 
                  label: Text("Favoritos")),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value){
                setState(() {
                  selectedIndex = value;
                });
              },
            )
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,)),
        ],)
    );
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
                    appState.getSiguiente();
                  }, 
                child: Text("Siguiente")),
              ],
            ),
          ],
        ),
      );
  }
}