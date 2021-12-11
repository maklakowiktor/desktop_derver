import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart';

Future testWindowFunctions() async {
  // Size size = await DesktopWindow.getWindowSize();
  // print(size);
  await DesktopWindow.setWindowSize(Size(1366, 768));

  // await DesktopWindow.setMinWindowSize(Size(400, 400));
  // await DesktopWindow.setMaxWindowSize(Size(800, 800));

  // await DesktopWindow.resetMaxWindowSize();
  // await DesktopWindow.toggleFullScreen();
  // bool isFullScreen = await DesktopWindow.getFullScreen();
  // await DesktopWindow.setFullScreen(true);
  // await DesktopWindow.setFullScreen(false);
}
