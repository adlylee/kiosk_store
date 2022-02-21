class Kasir {
  int _idJual;
  String _noPesanan;
  String _tanggal;
  String _noCart;
  String _diskon;
  String _total;

  Kasir(this._tanggal,this._noPesanan,this._noCart,this._diskon,this._total);

  Kasir.fromMap(Map<String,dynamic> map){
    this._idJual = map['id_jual'];
    this._tanggal = map['tanggal'];
    this._noPesanan = map['no_pesanan'];
    this._noCart = map['no_cart'];
    this._diskon = map['diskon'];
    this._total = map['total'];
  }

  int get idJual => _idJual;
  String get tanggal => _tanggal;
  String get noPesanan => _noPesanan;
  String get noCart => _noCart;
  String get diskon => _diskon;
  String get total => _total;

  set tanggal(String value){
    _tanggal = value;
  }

  set noPesanan(String value){
    _noPesanan = value;
  }

  set noCart(String value){
    _noCart = value;
  }

  set diskon(String value){
    _diskon = value;
  }

  set total(String value){
    _total = value;
  }

  Map<String,dynamic> toMap(){
    Map<String,dynamic> map = Map<String,dynamic>();
    map['id_jual'] = idJual;
    map['no_pesanan'] = noPesanan;
    map['tanggal'] = tanggal;
    map['no_cart'] = noCart;
    map['diskon'] = diskon;
    map['total'] = total;
    return map;
  }
}