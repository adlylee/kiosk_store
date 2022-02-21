class Barang {
  int _idBarang;
  String _namaBarang;
  String _harga;

  Barang(this._namaBarang,this._harga);

  Barang.fromMap(Map<String,dynamic> map){
    this._idBarang = map['id_barang'];
    this._namaBarang = map['nama_barang'];
    this._harga = map['harga'];
  }

  int get idBarang => _idBarang;
  String get namaBarang => _namaBarang;
  String get price => _harga;

  set namaBarang(String value){
    _namaBarang = value;
  }

  set price(String value){
    _harga = value;
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = Map<String,dynamic>();
    map['id_barang'] = idBarang;
    map['nama_barang'] = namaBarang;
    map['harga'] = price;
    return map;
  }
}