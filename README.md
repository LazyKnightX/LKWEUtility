# LKWEUtility [开发中]
Lazy Knight 的魔兽地图编辑器脚本脚手架，用于制作魔兽争霸III以及其资料片冰封王座的MOD（魔兽地图）。

本框架适用于1.31.8以上版本的YDWE，并且需要用户有安装对应DzAPI、11API等库。

目前还在开发中状态，包含各种BUG，请勿使用。

## VString
Value String，VString 是一个将整数压缩为字符串的工具，本工具目前可以将小于（不包含“等于”）8649（93^2）的整数压缩到2个字符中。

TODO：VString的StringMap并不完整，还能够增加更多字符。

## String
String 包含了对字符串的一系列处理拓展，使用本工具可以更方便地处理魔兽地图中的字符串数据。

## PString
Piece String，PString 是有固定长度的字符串，通常会规定字符串每一个位的使用规则。

## PVString
Piece Value String，PVString 是有固定长度的VString，通常会规定字符串每一个位的使用规则。
