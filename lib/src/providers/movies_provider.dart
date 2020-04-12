import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:movies_app/src/models/movie_model.dart';
import 'package:movies_app/src/models/actor_model.dart';

class MoviesProvider {
  String _apiKey = "f6524a4f74084480622a10ae730662d2";
  String _url = "api.themoviedb.org";
  String _language = "en-US";

  int _popularMoviesPage = 0;
  bool _loading = false;

  List<Movie> _popularMovies = new List();

  final _popularMoviesStreamController = StreamController<List<Movie>>.broadcast();

  Function(List<Movie>) get popularMoviesSink => _popularMoviesStreamController.sink.add;

  Stream<List<Movie>> get popularMoviesStream => _popularMoviesStreamController.stream;

  void disposeStreams() {
    _popularMoviesStreamController?.close();
  }

  Future<List<Movie>> _processResponse(Uri url) async {
    final response = await http.get(url);
    final decodedData = json.decode(response.body);
    final movies = new Movies.fromJsonList(decodedData['results']);
    return movies.items;
  }

  Future<List<Movie>> getInCinema() async {
    final url = Uri.https(_url, "3/movie/now_playing", {
      'api_key' : _apiKey,
      'language': _language
    });

    return await _processResponse(url);
  }

  Future<List<Movie>> getPopularMovies() async {

    if (_loading) return [];

    _loading = true;
    _popularMoviesPage ++;

    final url = Uri.https(_url, "3/movie/popular", {
      'api_key': _apiKey,
      'language': _language,
      'page': _popularMoviesPage.toString()
    });

    final response = await _processResponse(url);

    _popularMovies.addAll(response);
    popularMoviesSink(_popularMovies);
    _loading = false;
    return response;
  }

  Future<List<Actor>> getCast(String movieId) async {
    final url = Uri.https(_url, '3/movie/$movieId/credits', {
      'api_key' : _apiKey,
      'language': _language
    });

    final response = await http.get(url);
    final decodedData = json.decode(response.body);
    final cast = new Cast.fromJsonList(decodedData['cast']);
    return cast.actors;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_url, "3/search/movie", {
      'api_key' : _apiKey,
      'language': _language,
      'query': query
    });

    return await _processResponse(url);
  }
}