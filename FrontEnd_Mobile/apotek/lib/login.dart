import 'package:apotek/Theme/ColorStyle.dart';
import 'package:apotek/main.dart';
import 'package:flutter/material.dart';

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
                                const Text(
                                  "Apotik Bantarangin",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  "General Hospital",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
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
                      const Text(
                        "Selamat Datang!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                                    "Email",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Padding(padding: EdgeInsets.only(right: 4)),
                                  Text(
                                    "*",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: ColorStyle.button_red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                height: 8), // Jarak antara label dan input
                            Container(
                              height: 44,
                              // width: 400,
                              width: double.infinity,
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //       color: ColorStyle.fill_stroke, width: 1),
                              //   color: ColorStyle.fill_form,
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                              child: TextField(
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(
                                  //     horizontal: 12, vertical: 5),
                                  contentPadding:
                                      EdgeInsets.only(left: 8, bottom: 8),

                                  hintText: "Enter Email",
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

                                  // Border saat error
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorStyle.button_red,
                                        width: 1), // Warna merah jika error
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Padding(padding: EdgeInsets.only(right: 4)),
                                  Text(
                                    "*",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: ColorStyle.button_red),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 44,
                              width: double.infinity,
                              // width: 400,
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //       color: ColorStyle.fill_stroke, width: 1),
                              //   color: ColorStyle.fill_form,
                              //   borderRadius: BorderRadius.circular(10),
                              // ),
                              child: TextField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  // contentPadding: EdgeInsets.symmetric(
                                  //     horizontal: 12, vertical: 5),
                                  contentPadding:
                                      EdgeInsets.only(left: 8, bottom: 8),
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

                                  // Border saat error
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ColorStyle.button_red,
                                        width: 1), // Warna merah jika error
                                    borderRadius: BorderRadius.circular(8),
                                  ),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyApp()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: ColorStyle.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("MASUK",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
