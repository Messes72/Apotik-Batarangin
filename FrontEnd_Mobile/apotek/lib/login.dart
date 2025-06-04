import 'dart:convert';

import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:apotek/global.dart' as globals;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login2 extends StatelessWidget {
  const Login2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Apotek',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginPage();
}

class LoginPage extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool _validasiTerisi = false;
  bool isLoading = false;

  var _email = TextEditingController();
  var _password = TextEditingController();
  Future<void> login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return; // Hentikan jika form tidak valid
    }
    setState(() {
      isLoading = true;
    });

    final username = _email.text.trim();
    final password = _password.text.trim();

    try {
      final response = await http.post(
        Uri.parse('http://leap.crossnet.co.id:2688/login'),
        headers: {'x-api-key': '${globals.xApiKey}'},
        body: {"username": username, "password": password},
      );
      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data['data']['jwttoken']);
        setState(() {
          globals.token = data['data']['jwttoken'];
          globals.nama = data['data']['nama'];
        });
        print(globals.token);
        print(globals.nama);

        // Simpan token di lokal
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', globals.token);
        await prefs.setString('nama', globals.nama);

        // Navigasi ke halaman utama
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Login gagal, periksa kembali kredensial!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan saat login.")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // NANTI DIHAPUS YA jangan LUPAAAAAAAA !!!!!!!!!!!!!!!!!!!!!!!!!!!
  @override
  void initState() {
    super.initState();

    // 🔐 Hardcoded credentials
    _email.text = "admin"; // ganti sesuai user default
    _password.text = "admin"; // ganti sesuai password default

    // 🔁 Delay 1 detik lalu langsung login
    Future.delayed(Duration(seconds: 1), () {
      login(context); // langsung login otomatis
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background Gambar (Bagian Kiri)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // 60% layar
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/background.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // 🔹 Form Login (Bagian Kanan)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5, // 50% layar
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 40,
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      20, // Agar tidak tertutup keyboard
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("images/logo_apotik.png", height: 100),
                            const SizedBox(width: 16),

                            Flexible(
                              child: Column(
                                children: [
                                  Text(
                                    "Apotik Bantarangin",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "General Hospital",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Text("Apotik Bantarangin\nGeneral Hospital",
                            //     textAlign: TextAlign.center,
                            //     style: GoogleFonts.montserrat(
                            //         textStyle: TextStyle(
                            //             color: Colors.black, fontSize: 24)
                            //         //   fontWeight: FontWeight.bold,),
                            //         )),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // 🔹 Text Selamat Datang
                        Text(
                          "Selamat Datang!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          width: 400,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Label Email
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      "Username",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Padding(padding: EdgeInsets.only(right: 4)),
                                    Text(
                                      "*",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: ColorStyle.button_red),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                  height: 8), // Jarak antara label dan input
                              TextFormField(
                                cursorColor: Colors.black,
                                controller: _email,
                                onChanged: (value) {
                                  if (_validasiTerisi == true) {
                                    _formKey.currentState?.validate();
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Username harus diisi";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(
                                  //     horizontal: 12, vertical: 5),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                  isDense: true,
                                  hintText: "Enter Username",

                                  filled: true,
                                  fillColor: ColorStyle.fill_form,
                                  hintStyle: TextStyle(
                                    color: ColorStyle.tulisan_form,
                                    fontSize: 18,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorStyle.fill_stroke,
                                        width: 1), // Warna abu-abu
                                    borderRadius: BorderRadius.circular(8),
                                  ),

                                  // Border saat ditekan (fokus)
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black,
                                        width: 1), // Warna biru saat fokus
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorStyle.button_red,
                                        width: 1), // Warna biru saat fokus
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  // Border saat error
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorStyle.button_red,
                                        width: 1), // Warna merah jika error
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                  height: 16), // Spasi antara Email & Password

                              // 🔹 Label Password
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  children: [
                                    Text(
                                      "Password",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Padding(padding: EdgeInsets.only(right: 4)),
                                    Text(
                                      "*",
                                      style: GoogleFonts.inter(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: ColorStyle.button_red),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                cursorColor: Colors.black,
                                controller: _password,
                                obscureText: true,
                                onChanged: (value) {
                                  if (_validasiTerisi == true) {
                                    _formKey.currentState?.validate();
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Password harus diisi";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(
                                  //     horizontal: 12, vertical: 5),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                  hintText: "Password",
                                  filled: true,
                                  fillColor: ColorStyle.fill_form,
                                  hintStyle: TextStyle(
                                    color: ColorStyle.tulisan_form,
                                    fontSize: 18,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorStyle.fill_stroke,
                                        width: 1), // Warna abu-abu
                                    borderRadius: BorderRadius.circular(8),
                                  ),

                                  // Border saat ditekan (fokus)
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black,
                                        width: 1), // Warna biru saat fokus
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorStyle.button_red,
                                        width: 1), // Warna biru saat fokus
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  // Border saat error
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorStyle.button_red,
                                        width: 1), // Warna merah jika error
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(padding: EdgeInsets.only(bottom: 70)),

                        SizedBox(
                          width: 400,
                          // width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _validasiTerisi = true;
                              if (_formKey.currentState!.validate()) {
                                login(context);
                              }
                              // login(context);
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => MyApp()),
                              // );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: ColorStyle.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("MASUK",
                                style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: LoadingAnimationWidget.flickr(
                    leftDotColor: Colors.red,
                    rightDotColor: Colors.blue,
                    size: 50,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
