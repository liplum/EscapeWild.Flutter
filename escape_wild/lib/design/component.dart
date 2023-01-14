import 'theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rettulf/rettulf.dart';

class LeavingBlank extends StatelessWidget {
  final WidgetBuilder iconBuilder;
  final String desc;
  final VoidCallback? onIconTap;
  final Widget? subtitle;

  const LeavingBlank.builder({super.key, required this.iconBuilder, required this.desc, this.onIconTap, this.subtitle});

  factory LeavingBlank({
    Key? key,
    required IconData icon,
    required String desc,
    VoidCallback? onIconTap,
    double size = 120,
    Widget? subtitle,
  }) {
    return LeavingBlank.builder(
      iconBuilder: (ctx) => icon.make(size: size, color: ctx.themeColor),
      desc: desc,
      onIconTap: onIconTap,
      subtitle: subtitle,
    );
  }

  factory LeavingBlank.svgAssets({
    Key? key,
    required String assetName,
    required String desc,
    VoidCallback? onIconTap,
    double width = 120,
    double height = 120,
    Widget? subtitle,
  }) {
    return LeavingBlank.builder(
      iconBuilder: (ctx) => SvgPicture.asset(assetName, width: width, height: height),
      desc: desc,
      onIconTap: onIconTap,
      subtitle: subtitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = iconBuilder(context).padAll(20);
    if (onIconTap != null) {
      icon = icon.on(tap: onIconTap);
    }
    final sub = subtitle;
    if (sub != null) {
      return [
        icon.expanded(),
        [
          buildDesc(context),
          sub,
        ].column().expanded(),
      ].column(maa: MAAlign.spaceAround, mas: MainAxisSize.min).center();
    } else {
      return [
        icon.expanded(),
        buildDesc(context).expanded(),
      ].column(maa: MAAlign.spaceAround, mas: MainAxisSize.min).center();
    }
  }

  Widget buildDesc(BuildContext ctx) {
    return desc
        .text(
          style: ctx.textTheme.titleLarge,
          textAlign: TextAlign.center,
        )
        .center()
        .padAll(10);
  }
}

class NavigationListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final WidgetBuilder? to;

  const NavigationListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.to,
  });

  @override
  Widget build(BuildContext context) {
    final to = this.to;
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: to == null
          ? null
          : () {
              context.navigator.push(MaterialPageRoute(builder: to));
            },
      trailing: to == null
          ? null
          : const Icon(
              Icons.navigate_next_rounded,
            ),
    );
  }
}
