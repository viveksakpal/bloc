import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class MyHydratedBlocDelegate extends HydratedBlocDelegate {
  MyHydratedBlocDelegate(HydratedBlocSharedPreferences prefs) : super(prefs);

  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print('${bloc.runtimeType} $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('${bloc.runtimeType} $transition');
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('${bloc.runtimeType} $error');
  }
}

void main() async {
  final prefs = await HydratedBlocSharedPreferences.getInstance();
  BlocSupervisor.delegate = MyHydratedBlocDelegate(prefs);
  runApp(App());
}

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  final CounterBloc _counterBloc = CounterBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProviderTree(
      blocProviders: [
        BlocProvider<CounterBloc>(bloc: _counterBloc),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        home: CounterPage(),
      ),
    );
  }

  @override
  void dispose() {
    _counterBloc.dispose();
    super.dispose();
  }
}

class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc _counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterEvent, CounterState>(
        bloc: _counterBloc,
        builder: (BuildContext context, CounterState state) {
          return Center(
            child: Text(
              '${state.value}',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                _counterBloc.dispatch(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}

enum CounterEvent { increment, decrement }

class CounterState {
  int value;

  CounterState(this.value);
}

class CounterBloc extends HydratedBloc<CounterEvent, CounterState> {
  @override
  CounterState get initialState {
    return super.initialState ?? CounterState(0);
  }

  @override
  Stream<CounterState> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield CounterState(currentState.value - 1);
        break;
      case CounterEvent.increment:
        yield CounterState(currentState.value + 1);
        break;
    }
  }

  @override
  fromJson(String source) {
    try {
      final dynamic j = json.decode(source);
      return CounterState(j['value'] as int);
    } catch (_) {
      return null;
    }
  }

  @override
  String toJson(CounterState state) {
    Map<String, int> j = {'value': state.value};
    return json.encode(j);
  }
}