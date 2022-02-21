import 'dart:math';

import 'package:flutter/material.dart';
import './models/barang.dart';
import './models/stokBarang.dart';
import './models/kasir.dart';
import './models/cart.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import './helpers/helpers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        primaryColor: Color.fromRGBO(244, 202, 62, 1.0),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Point of Sales'),
      routes: {
        DataBarang.routeName: (context) => DataBarang(),
        DataStok.routeName: (context) => DataStok(),
        Penjualan.routeName: (context) => Penjualan(),
        Keranjang.routeName: (context) => Keranjang(),
        // '/laporan': (context) => Laporan(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 3;
    final double itemWidth = size.width / 2;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Color.fromRGBO(244, 111, 62, 1.0),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
        bottomOpacity: 0.0,
      ),
      body: Stack(children: [
        Container(
          height: size.height * .3,
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 50.0, horizontal: 1.0),
          child: (GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(6.0),
            childAspectRatio: (itemWidth / itemHeight),
            children: [
              dashboardItem("Data Barang", context, DataBarang.routeName),
              dashboardItem("Data Stok", context, DataStok.routeName),
              dashboardItem("Penjualan", context, Penjualan.routeName),
              // dashboardItem("Laporan", context, '/laporan')
            ],
          )),
        ),
      ]),
    );
  }
}

Card dashboardItem(String title, BuildContext context, String route) {
  return Card(
    elevation: 20.0,
    margin: new EdgeInsets.all(8.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: AssetImage(
              'assets/images/liquid-cheese.png'), //this image is provided by https://www.svgbackgrounds.com/
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: new InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, route);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: [
            SizedBox(
              height: 90.0,
            ),
            new Center(
              child: new Text(
                title,
                style: new TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class DataBarang extends StatefulWidget {
  const DataBarang({Key key}) : super(key: key);
  static const routeName = '/dataBarang';

  @override
  _DataBarangState createState() => _DataBarangState();
}

class _DataBarangState extends State<DataBarang> {
  Helpers helper = Helpers();
  int count = 0;
  List<Barang> barangList;

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    if (barangList == null) {
      barangList = List<Barang>();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Barang"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: barangList.isEmpty
              ? Center(
                  child: Text('Data Tidak Ada'),
                )
              : ListView.builder(
                  itemCount: count,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title: Text(this.barangList[index].namaBarang),
                        subtitle: Text('Rp : ' + this.barangList[index].price),
                        trailing: GestureDetector(
                          child: Icon(Icons.delete),
                          onTap: () {
                            deleteBarang(barangList[index]);
                          },
                        ),
                        onTap: () async {
                          var barang = await navigateToBarang(
                              context, this.barangList[index]);
                          if (barang != null) editBarang(barang);
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var barang = await navigateToBarang(context, null);
          if (barang != null) addBarang(barang);
        },
      ),
    );
  }

  Future<Barang> navigateToBarang(BuildContext context, Barang barang) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return InputFormBarang(barang);
    }));
    return result;
  }

  void addBarang(Barang object) async {
    int result = await helper.insertBarang(object);
    if (result > 0) {
      updateListView();
    }
  }

  void editBarang(Barang object) async {
    int result = await helper.updateBarang(object);
    if (result > 0) {
      updateListView();
    }
  }

  void deleteBarang(Barang object) async {
    int result = await helper.deleteBarang(object.idBarang);
    if (result > 0) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = helper.initDb();
    dbFuture.then((database) {
      Future<List<Barang>> barangListFuture = helper.getBarangList();
      barangListFuture.then((barangList) {
        setState(() {
          this.barangList = barangList;
          this.count = barangList.length;
        });
      });
    });
  }
}

class InputFormBarang extends StatefulWidget {
  final Barang barang;

  InputFormBarang(this.barang);

  @override
  _InputFormBarangState createState() => _InputFormBarangState(this.barang);
}

class _InputFormBarangState extends State<InputFormBarang> {
  Barang barang;

  _InputFormBarangState(this.barang);

  TextEditingController namaBarangController = TextEditingController();
  TextEditingController hargaBarangController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (barang != null) {
      namaBarangController.text = barang.namaBarang;
      hargaBarangController.text = barang.price;
    }
    return Scaffold(
      appBar: AppBar(
        title: barang == null ? Text('Tambah Barang') : Text('Ubah Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: namaBarangController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Nama Barang",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: hargaBarangController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Harga Barang",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (barang == null) {
                    barang = Barang(
                        namaBarangController.text, hargaBarangController.text);
                  } else {
                    barang.namaBarang = namaBarangController.text;
                    barang.price = hargaBarangController.text;
                  }
                  Navigator.pop(context, barang);
                },
                child: Text("Simpan"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DataStok extends StatefulWidget {
  const DataStok({Key key}) : super(key: key);
  static const routeName = '/dataStok';

  @override
  _DataStokState createState() => _DataStokState();
}

class _DataStokState extends State<DataStok> {
  Helpers helper = Helpers();
  int count = 0;
  List<StokBarang> stokList;

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    if (stokList == null) {
      stokList = List<StokBarang>();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Stok"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: stokList.isEmpty
              ? Center(
                  child: Text('Data Tidak Ada'),
                )
              : ListView.builder(
                  itemCount: count,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              this.stokList[index].tipeBarang,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Spacer(),
                            Text(this.stokList[index].namaBarang),
                          ],
                        ),
                        subtitle: Row(
                          children: [
                            Text('Stok : ' + this.stokList[index].stok),
                            Spacer(),
                            Text('Rp : ' + this.stokList[index].price),
                          ],
                        ),
                        trailing: GestureDetector(
                          child: Icon(Icons.delete),
                          onTap: () {
                            // deleteBarang(barangList[index]);
                          },
                        ),
                        onTap: () async {
                          var stokBarang = await navigateToStok(
                              context, this.stokList[index]);
                          if (stokBarang != null) editStokBarang(stokBarang);
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var stokBarang = await navigateToStok(context, null);
          if (stokBarang != null) addStokBarang(stokBarang);
        },
      ),
    );
  }

  Future<StokBarang> navigateToStok(
      BuildContext context, StokBarang stokBarang) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return InputFormStok(stokBarang);
    }));
    return result;
  }

  void addStokBarang(StokBarang object) async {
    int result = await helper.insertStok(object);
    if (result > 0) {
      updateListView();
    }
  }

  void editStokBarang(StokBarang object) async {
    int result = await helper.updateStok(object);
    if (result > 0) {
      updateListView();
    }
  }

  void deleteStokBarang(StokBarang object) async {
    int result = await helper.deleteStok(object.idStok);
    if (result > 0) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = helper.initDb();
    dbFuture.then((database) {
      Future<List<StokBarang>> stokListFuture = helper.getStokList();
      stokListFuture.then((stokList) {
        setState(() {
          this.stokList = stokList;
          this.count = stokList.length;
        });
      });
    });
  }
}

class InputFormStok extends StatefulWidget {
  final StokBarang stokBarang;

  InputFormStok(this.stokBarang);

  @override
  _InputFormStokState createState() => _InputFormStokState(this.stokBarang);
}

class _InputFormStokState extends State<InputFormStok> {
  StokBarang stokBarang;

  Helpers helper = Helpers();
  int count = 0;
  Barang barang;
  List<Barang> barangList = <Barang>[];

  _InputFormStokState(this.stokBarang);

  TextEditingController tipeBarangController = TextEditingController();
  TextEditingController stokBarangController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (stokBarang != null) {
      listBarangById(stokBarang.idBarang);
    } else {
      listBarang();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stokBarang != null) {
      tipeBarangController.text = stokBarang.tipeBarang;
      stokBarangController.text = stokBarang.stok;
    }
    return Scaffold(
      appBar: AppBar(
        title: stokBarang == null ? Text('Tambah Stok') : Text('Ubah Barang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            stokBarang == null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButtonFormField(
                      value: barang,
                      hint: Text('Cari Barang'),
                      items: barangList.map((barangBarang) {
                        return DropdownMenuItem(
                          child: new Text(barangBarang.namaBarang),
                          value: barangBarang,
                        );
                      }).toList(),
                      onChanged: (Barang barangBarang) {
                        setState(() {
                          barang = barangBarang;
                        });
                      },
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: tipeBarangController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Tipe Barang",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: stokBarangController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Stok Barang",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  if (stokBarang == null) {
                    String vale = barang.idBarang.toString();
                    stokBarang = StokBarang(vale, tipeBarangController.text,
                        stokBarangController.text);
                  } else {
                    stokBarang.tipeBarang = tipeBarangController.text;
                    stokBarang.stok = stokBarangController.text;
                  }
                  Navigator.pop(context, stokBarang);
                },
                child: Text("Simpan"),
              ),
            )
          ],
        ),
      ),
    );
  }

  void listBarang() {
    final Future<Database> dbFuture = helper.initDb();
    dbFuture.then((database) {
      Future<List<Barang>> barangListFuture = helper.getBarangList();
      barangListFuture.then((barangList) {
        setState(() {
          this.barangList = barangList;
          this.count = barangList.length;
        });
      });
    });
  }

  void listBarangById(id) {
    final Future<Database> dbFuture = helper.initDb();
    dbFuture.then((database) {
      Future<List<Barang>> barangFuture = helper.getBarangListById(id);
      barangFuture.then((barangList) {
        setState(() {
          this.barangList = barangList;
        });
      });
    });
  }
}

class Penjualan extends StatelessWidget {
  static const routeName = '/penjualan';
  const Penjualan({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Penjualan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          child: Center(
            child: Text('Data Tidak Ada'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          var stokBarang = await navigateToJual(context, null);
          // if (stokBarang != null) addStokBarang(stokBarang);
        },
      ),
    );
  }

  Future<Kasir> navigateToJual(BuildContext context, Kasir kasir) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return InputFormJual(kasir);
    }));
    return result;
  }
}

class InputFormJual extends StatefulWidget {
  final Kasir kasir;

  InputFormJual(this.kasir);
  @override
  _InputFormJualState createState() => _InputFormJualState(this.kasir);
}

class _InputFormJualState extends State<InputFormJual> {
  Kasir kasir;
  Helpers helper = Helpers();
  List<StokBarang> stokList = <StokBarang>[];
  StokBarang stok;
  Cart cart;
  _InputFormJualState(this.kasir);

  TextEditingController hargaController = TextEditingController();
  TextEditingController jumlahController = TextEditingController();
  TextEditingController idCartController = TextEditingController();

  @override
  void initState() {
    super.initState();
    listStok();
    idCartController.text = randomNumber().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kasir'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () async {
              await Navigator.pushNamed(context, Keranjang.routeName);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: idCartController,
                enabled: false,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField(
                value: stok,
                hint: Text('Cari Barang'),
                items: stokList.map((stok) {
                  return DropdownMenuItem(
                    child: new Text(stok.tipeBarang),
                    value: stok,
                  );
                }).toList(),
                onChanged: (StokBarang stokstok) {
                  setState(() {
                    hargaController.text = stokstok.price;
                    stok = stokstok;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: jumlahController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Jumlah",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                enabled: false,
                controller: hargaController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Harga",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  int idStok = stok.idStok;
                  if (idStok != null) {
                    cart = Cart(
                        idCartController.text,
                        idStok,
                        int.parse(jumlahController.text),
                        int.parse(hargaController.text),
                        '0');
                    addCart(cart);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: [
                                  Text(
                                    "Apakah anda ingin menambahkan barang lagi ke keranjang ?",
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.grey),
                                        ),
                                        onPressed: () {},
                                        child: Text('Tidak'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            stok = null;
                                          });
                                          jumlahController.clear();
                                          hargaController.clear();
                                          Navigator.pop(context, 'Ya');
                                        },
                                        child: Text(
                                          'Ya',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(
                                                67, 52, 102, 1.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: Text('Gagal Simpan'),
                          ),
                        );
                      },
                    );
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_shopping_cart,
                      color: Color.fromRGBO(67, 52, 102, 1.0),
                    ),
                    Text(
                      "Tambah Ke Keranjang",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(67, 52, 102, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void addCart(Cart object) async {
    int result = await helper.insertCart(object);
    if (result > 0) {
      // updateListView();
    }
  }

  int randomNumber() {
    var rng = new Random();
    var code = rng.nextInt(900000) + 100000;
    return code;
  }

  void listStok() {
    final Future<Database> dbFuture = helper.initDb();
    dbFuture.then((database) {
      Future<List<StokBarang>> stokListFuture = helper.getStokListNotEmpty();
      stokListFuture.then((stokList) {
        setState(() {
          this.stokList = stokList;
        });
      });
    });
  }
}

class Keranjang extends StatefulWidget {
  static const routeName = '/keranjang';
  @override
  _KeranjangState createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  Helpers helper = Helpers();
  List<Cart> kartList;
  List<Cart> kartListValue;
  int count = 0;
  int countValue = 0;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    updateListView();
    if (kartList != null) {
      //   kartList = List<Cart>();
      for (int i = 0; i < count; i++) {
        updateListViewValue(kartList[i].noCart);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kartList == null) {
      kartList = List<Cart>();
    }
    if (kartListValue == null) {
      kartListValue = List<Cart>();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Keranjang'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: kartList.isEmpty
            ? Center(
                child: Text('Data Tidak Ada'),
              )
            : ListView.builder(
                itemCount: count,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _checked,
                              onChanged: (bool newChecked) {
                                setState(() {
                                  _checked = newChecked;
                                });
                              },
                            ),
                            Text(
                              this.kartList[index].noCart,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        getListKeranjang(kartListValue),
                        // ListView.builder(
                        //     itemCount: countValue,
                        //     itemBuilder: (BuildContext context, int i) {
                        //       return Card(
                        //         child: ListTile(
                        //           leading: Checkbox(
                        //             value: _checked,
                        //             onChanged: (bool newChecked) {
                        //               setState(() {
                        //                 _checked = newChecked;
                        //               });
                        //             },
                        //           ),
                        //           title: Row(
                        //             children: [
                        //               Text(
                        //                 this.kartListValue[i].namaBarang,
                        //                 style: TextStyle(
                        //                   fontWeight: FontWeight.bold,
                        //                   fontSize: 18,
                        //                 ),
                        //               ),
                        //               Spacer(),
                        //               Text(
                        //                 this.kartListValue[i].tipeBarang,
                        //               ),
                        //             ],
                        //           ),
                        //           subtitle: Row(
                        //             children: [
                        //               Text(
                        //                 'Jumlah : ' +
                        //                     this
                        //                         .kartListValue[i]
                        //                         .jumlah
                        //                         .toString(),
                        //               ),
                        //               Spacer(),
                        //               Text(
                        //                 this.kartListValue[i].harga.toString(),
                        //               ),
                        //             ],
                        //           ),
                        //           trailing: GestureDetector(
                        //             child: Icon(Icons.delete),
                        //             onTap: () {
                        //               deleteKeranjang(kartListValue[i]);
                        //             },
                        //           ),
                        //         ),
                        //       );
                        //     }),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget getListKeranjang(List<Cart> kart) {
    return new Row(
        children: List.generate(kart.length, (index) {
      return Text(kart[index].namaBarang);
    }));
  }

  void deleteKeranjang(Cart object) async {
    int result = await helper.deleteCart(object.idCart);
    if (result > 0) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = helper.initDb();
    dbFuture.then((database) {
      Future<List<Cart>> kartListFuture = helper.getCartList();
      kartListFuture.then((kartList) {
        setState(() {
          this.kartList = kartList;
          this.count = kartList.length;
        });
      });
    });
  }

  void updateListViewValue(String id) {
    final Future<Database> dbFuture = helper.initDb();
    dbFuture.then((database) {
      Future<List<Cart>> kartListFuture = helper.getCartListValue(id);
      kartListFuture.then((kartList) {
        setState(() {
          this.kartListValue = kartList;
          this.countValue = kartList.length;
        });
      });
    });
  }
}

class Laporan extends StatelessWidget {
  const Laporan({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
