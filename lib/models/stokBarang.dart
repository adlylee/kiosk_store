class StokBarang {
  int _idStok;
  String _idBarang;
  String _namaBarang;
  String _tipeBarang;
  String _harga;
  String _stok;

  StokBarang(this._idBarang, this._tipeBarang, this._stok);

  StokBarang.fromMap(Map<String, dynamic> map) {
    this._idStok = map['id_stok'];
    this._idBarang = map['id_barang'];
    this._namaBarang = map['nama_barang'];
    this._tipeBarang = map['tipe_barang'];
    this._harga = map['harga'];
    this._stok = map['stok'];
  }

  int get idStok => _idStok;
  String get idBarang => _idBarang;
  String get namaBarang => _namaBarang;
  String get tipeBarang => _tipeBarang;
  String get price => _harga;
  String get stok => _stok;

  set tipeBarang(String value) {
    _tipeBarang = value;
  }

  set namaBarang(String value) {
    _namaBarang = value;
  }

  set stok(String value) {
    _stok = value;
  }

  set idBarang(String value) {
    _idBarang = value;
  }

  set price(String value){
    _harga = value;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = Map<String, dynamic>();
    map['id_stok'] = this._idStok;
    map['id_barang'] = idBarang;
    map['tipe_barang'] = tipeBarang;
    map['stok'] = stok;
    return map;
  }

  String toStringBarang(){
    return '{${this._idBarang}}';
  }
}
