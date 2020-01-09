class Usuario{
  final String uid;
  final String foto;
  final String nombre;
  List<Ubicacion> ubiCazas = new List<Ubicacion>();

  Usuario({this.uid, this.foto, this.nombre});

  int numCazas(){
    return ubiCazas.length;
  }

}

class Ubicacion{
  final double latitud;
  final double longitud;

  const Ubicacion({this.latitud, this.longitud});

  Map<String, dynamic> toJson(){
    return {
      'latitud': this.latitud,
      'longitud': this.longitud
    };
  }

}