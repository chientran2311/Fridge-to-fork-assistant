import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Color cardColor = const Color(0xFFE7EEE9);
  final Color textColor = const Color(0xFF214130);

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cardColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===========================
            // HEADER
            // ===========================
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: textColor,
              ),
              child: Stack(
                children: [
                  // Nút Back
                  Positioned(
                    top: 45,
                    left: 15,
                    child: _rectangleBtn(Icons.arrow_back, textColor),
                  ),

                  // Nút Edit
                  Positioned(
                    top: 45,
                    right: 15,
                    child: _rectangleBtn(Icons.edit, textColor),
                  ),

                  // TITLE My profile (chữ trắng, font Merriweather)
                  Positioned(
                    top: 112, // đẩy xuống dưới nút back
                    left: 20,
                    child: Text(
                      "My profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // TITLE

            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE7EEE9), // cardColor
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE

                  Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.4),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(20),
                          right: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PROFILE INFO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            "assets/images/dreammy_bull.png",
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Dreammy Bull",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "18 years old",
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // LIKES
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 18),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 186, 223, 196),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _pillButton(Icons.thumb_up, "Like"),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 18),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 186, 223, 196),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: _pillButton(null, "4 likes"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ADD FRIEND & SHARE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // ADD FRIEND — chiếm 80%
                        Expanded(
                          flex: 8,
                          child: _borderButton(Icons.group_add, "Add friend"),
                        ),

                        const SizedBox(width: 10),

                        // SHARE — chiếm 20%
                        Expanded(
                          flex: 2,
                          child: _borderIconButton(Icons.share),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // OVERVIEW TITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Overview",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _overviewCard(
                          icon: Icons.local_fire_department,
                          title: "7 days",
                          subtitle: "Total streak",
                        ),
                        const SizedBox(width: 12),
                        _overviewCard(
                          icon: Icons.flag,
                          title: "69",
                          subtitle: "recipes done",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // FAVORITE TITLE
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "My favorite recipe",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/myrecipe.png",
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ===========================
  // WIDGETS
  // ===========================

  Widget _rectangleBtn(IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _pillButton(IconData? icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Quan trọng: giúp nội dung nằm đúng giữa
      children: [
        if (icon != null) ...[
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _borderButton(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor, width: 1.3),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _borderIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor, width: 1.3),
      ),
      child: Icon(icon, color: textColor, size: 22),
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 186, 223, 196),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
