import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 태블릿/모바일(<1024px) 전용 상단바: 로고 + 햄버거(드로어 오픈).
/// AppBar 슬롯으로 사용되므로 build context가 Scaffold의 하위이며,
/// 그대로 Scaffold.of(context)로 endDrawer를 열 수 있다.
class WebGnbTopbar extends StatelessWidget implements PreferredSizeWidget {
  const WebGnbTopbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: SDSColor.snowliveWhite,
        border: Border(bottom: BorderSide(color: SDSColor.gray100)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/imgs/logos/snowliveLogo_main_new.png',
            height: 22,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: Icon(Icons.menu, color: SDSColor.gray900),
          ),
        ],
      ),
    );
  }
}
