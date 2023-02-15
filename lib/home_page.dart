import 'dart:io';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:pdf/pdf.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> hasilList = [];
  List<Item> _pertanyaan = [];

  PDFDocument document = new PDFDocument();

  @override
  void initState() {
    super.initState();
    this._pertanyaan = [
      new Item(0, "Pertanyaan 1",
          "Apakah console ini memiliki game fisik dan digital?", false),
      new Item(
          1, "Pertanyaan 2", "Apakah console ini berasal dari jepang?", false),
      new Item(
          2, "Pertanyaan 3", "Apakah console ini memiliki 3 play mode?", false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text("Pdf from Expandable"),
              backgroundColor: Colors.blue,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: this._pertanyaan.map((Item Itemcard) {
                      return ExpandableNotifier(
                          child: ScrollOnExpand(
                        scrollOnExpand: false,
                        scrollOnCollapse: true,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: <Widget>[
                                ScrollOnExpand(
                                  scrollOnExpand: true,
                                  scrollOnCollapse: false,
                                  child: ExpandableNotifier(
                                    initialExpanded: false,
                                    child: ExpandablePanel(
                                      header: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            Itemcard.judul,
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2,
                                          )),
                                      expanded: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 10),
                                                child: Text(Itemcard.isi)),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 10),
                                              child: FlutterSwitch(
                                                activeText: "Ya",
                                                inactiveText: "Tidak",
                                                value: Itemcard.status,
                                                valueFontSize: 10.0,
                                                width: 80,
                                                borderRadius: 30.0,
                                                showOnOff: true,
                                                onToggle: (val) {
                                                  setState(() {
                                                    this
                                                        ._pertanyaan[
                                                            Itemcard.index]
                                                        .status = val;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      builder: (_, collapsed, expanded) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              left: 10, right: 10, bottom: 10),
                                          child: Expandable(
                                            collapsed: collapsed,
                                            expanded: expanded,
                                          ),
                                        );
                                      },
                                      collapsed: Text(
                                        Itemcard.judul,
                                        softWrap: true,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ));
                    }).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: FloatingActionButton.extended(
                    heroTag: "hero2",
                    onPressed: () async {
                      final pdf = new pw.Document();
                      //Directory extDir = null;
                      var hasil = 0;
                      var jConsole = '';
                      var extDir;
                      if (Platform.isAndroid) {
                        extDir = await getExternalStorageDirectory();
                      } else {
                        extDir = await getTemporaryDirectory();
                      }
                      final file = File("${extDir.path}/example.pdf");

                      for (var i = 0; i < this._pertanyaan.length; i++) {
                        if (this._pertanyaan[i].status == true) {
                          hasil += 1;
                        }
                      }

                      if (hasil <= 1) {
                        jConsole = 'Microsoft XBOX';
                      } else if (hasil == 2) {
                        jConsole = 'Sony PlayStation';
                      } else {
                        jConsole = 'Nintendo Switch';
                      }
                      pdf.addPage(pw.Page(
                          pageFormat: PdfPageFormat.a4,
                          build: (pw.Context context) {
                            return pw.Center(
                              child: pw.Column(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.center,
                                  children: [
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(10),
                                      child: pw.Text("Hasil",
                                          style: pw.TextStyle(
                                            fontSize: 24,
                                          )),
                                    ),
                                    pw.Container(
                                      padding: pw.EdgeInsets.all(10),
                                      child: pw.Text(jConsole,
                                          style: pw.TextStyle(
                                              fontSize: 36,
                                              fontWeight: pw.FontWeight.bold)),
                                    ),
                                  ]),
                            ); // Center
                          }));
                      // await file.writeAsBytes(await pdf.save());
                      await Printing.layoutPdf(
                          onLayout: (PdfPageFormat format) async => pdf.save());
                      // this.document = await PDFDocument.fromFile(File(file.path));
                      // setState(() {
                      //   this.show_pdf = true;
                      // });
                    },
                    label: const Text(
                      'Cetak',
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: const Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.blue,
                  ),
                )
              ],
            )));
  }
}

class Item {
  int index;
  String judul;
  String isi;
  bool status;
  Item(this.index, this.judul, this.isi, this.status);
}
