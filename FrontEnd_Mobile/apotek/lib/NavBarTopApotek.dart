import 'package:apotek/Theme/ColorStyle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavbarTopApotek extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final bool isExpanded;

  final VoidCallback animationTrigger;
  final bool animation;

  const NavbarTopApotek(
      {super.key,
      required this.title,
      required this.onMenuPressed,
      required this.isExpanded,
      required this.animationTrigger,
      required this.animation});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    // final widthScreen = MediaQuery.of(context).size.width;
    print(isExpanded);
    return Container(
      decoration: BoxDecoration(color: ColorStyle.warna_form, boxShadow: [
        BoxShadow(
            color: ColorStyle.shadow.withOpacity(0.25),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(2, 1))
      ]),
      child: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(title, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            animationTrigger();
            onMenuPressed();
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => RotationTransition(
              turns: Tween<double>(
                      begin: animation ? 1 : 0.75, end: animation ? 0.75 : 1)
                  .animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: animation
                ? const Icon(
                    Icons.close,
                    color: Colors.black,
                    key: ValueKey('icon1'),
                  )
                : const Icon(
                    Icons.menu,
                    color: Colors.black,
                    key: ValueKey('icon2'),
                  ),
          ),
        ),
        actions: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
                "https://cdn.shopify.com/s/files/1/0416/8083/0620/files/01132022_soc_pinterestboardcoverupdate_CN_1200x1200_88c02180-90a1-4745-921e-341c191ec84a_480x480.png?v=1646098139") as ImageProvider,
          ),
          Padding(padding: EdgeInsets.only(right: 16)),
          Text("NAMA"),
          Padding(padding: EdgeInsets.only(right: 16))
        ],
      ),
    );
  }
}
