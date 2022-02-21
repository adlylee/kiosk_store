class Cart {
  int _idCart;
  int _idStok;
  String _isBayar;
  String _noCart;
  String _namaBarang;
  String _tipeBarang;
  int _jumlah;
  int _harga;

  Cart(this._noCart,this._idStok,this._jumlah,this._harga,this._isBayar);

  Cart.fromMap(Map<String,dynamic> map){
    this._idCart = map['id_cart'];
    this._noCart = map['no_cart'];
    this._idStok = map['id_stok'];
    this._namaBarang = map['nama_barang'];
    this._tipeBarang = map['tipe_barang'];
    this._jumlah = map['jumlah'];
    this._harga = map['harga'];
    this._isBayar = map['is_bayar'];
  }

  int get idCart => _idCart;
  String get noCart => _noCart;
  int get idStok => _idStok;
  String get namaBarang => _namaBarang;
  String get tipeBarang => _tipeBarang;
  int get jumlah => _jumlah;
  int get harga => _harga;
  String get isBayar => _isBayar;

  set idStok(int value){
    _idStok = value;
  }

  set jumlah(int value){
    _jumlah = value;
  }

  set noCart(String value){
    _noCart = value;
  }

  set namaBarang(String value){
    _namaBarang = value;
  }

  set tipeBarang(String value){
    _tipeBarang = value;
  }

  set harga(int value){
    _harga = value;
  }

  set isBayar(String value){
    _isBayar = value;
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = Map<String,dynamic>();
    map['id_cart'] = idCart;
    map['no_cart'] = noCart;
    map['id_stok'] = idStok;
    map['jumlah'] = jumlah;
    map['harga'] = harga;
    map['is_bayar'] = isBayar;
    return map;
  }
}