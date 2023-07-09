import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:populargo/common/widgets/custom_button.dart';
import 'package:populargo/constants/size_config.dart';
import 'package:populargo/constants/utils.dart';
import 'package:populargo/features/auth/services/auth_service.dart';
import 'package:provider/provider.dart';

import '../../../constants/global_variables.dart';
import '../../../providers/otp_provider.dart';

// get email
class ResetOTPScreen extends StatefulWidget {
  static const String routeName = '/reset-pwd-screen';
  const ResetOTPScreen({super.key});

  @override
  State<ResetOTPScreen> createState() => _ResetOTPScreenState();
}

class _ResetOTPScreenState extends State<ResetOTPScreen> {
  // global variable
  final _otpFormKey = GlobalKey<FormState>();
  final TextEditingController _pin1Controller = TextEditingController();
  final TextEditingController _pin2Controller = TextEditingController();
  final TextEditingController _pin3Controller = TextEditingController();
  final TextEditingController _pin4Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // final args = ModalRoute.of(context)!.settings.arguments as PassEmailOTP;
    return Scaffold(
      backgroundColor: GlobalVariables.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'OTP Verification',
          style: TextStyle(
            fontWeight: FontWeight.w400,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: getProportionateScreenHeight(20),
                    ),
                    const Text(
                      'Verification Code',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(10),
                    ),
                    Text(
                      'We sent your code to ${Provider.of<OTPProvider>(context, listen: false).email}',
                      style: GlobalVariables().subtextStyle,
                    ),
                    SizedBox(
                      height: getProportionateScreenHeight(40),
                    ),
                    OTPForm(
                      otpFormKey: _otpFormKey,
                      pin1Controller: _pin1Controller,
                      pin2Controller: _pin2Controller,
                      pin3Controller: _pin3Controller,
                      pin4Controller: _pin4Controller,
                    ),
                    // resend email text
                    // reset the {args.otpCode, timerDone, timer funtion()}
                  ],
                )),
          ),
        ),
      ),
    );
  }
}

// form
class OTPForm extends StatefulWidget {
  OTPForm(
      {required this.otpFormKey,
      required this.pin1Controller,
      required this.pin2Controller,
      required this.pin3Controller,
      required this.pin4Controller,
      super.key});
  // global variable
  var otpFormKey = GlobalKey<FormState>();
  TextEditingController pin1Controller = TextEditingController();
  TextEditingController pin2Controller = TextEditingController();
  TextEditingController pin3Controller = TextEditingController();
  TextEditingController pin4Controller = TextEditingController();

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> with TickerProviderStateMixin {
  // backend connection
  final AuthService authService = AuthService();
  late AnimationController _controller;
  late Animation<int> _animation;
  bool _isTimerRunning = false;

  void resetOTP() {
    authService.resetOTP(
      context: context,
      email: Provider.of<OTPProvider>(context, listen: false).email,
      otpCode: GlobalVariables.randomOTP(),
    );
  }

  void resetValidOTP() {
    authService.resetValidOTP(
        context: context,
        otpCode: Provider.of<OTPProvider>(context, listen: false).otpCode,
        pin1: widget.pin1Controller.text,
        pin2: widget.pin2Controller.text,
        pin3: widget.pin3Controller.text,
        pin4: widget.pin4Controller.text);
  }

  // String get countText {
  //   Duration count = controller.duration! * controller.value;
  //   return '${count.inSeconds}';
  // }

  // start the timer
  // void onStart() {
  //   controller.reverse(from: controller.value == 0 ? 1.0 : controller.value);
  // }

  FocusNode pin2FocusNode = FocusNode();
  FocusNode pin3FocusNode = FocusNode();
  FocusNode pin4FocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
    // controller = AnimationController(
    //     vsync: this, duration: const Duration(seconds: 30), value: 1)
    //   ..addStatusListener((AnimationStatus status) {
    //     if(status == AnimationStatus.completed) {
    //       print('times out!');
    //       // Provider.of<OTPProvider>(context, listen: false).setTimerDone(true);
    //     }
    //   });
    // onStart();
    Provider.of<OTPProvider>(context, listen: false).setTimerDone(false);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 30),
    );

    _animation = IntTween(begin: 30, end: 0).animate(_controller)
      ..addListener(() {
        setState(() {});
        if (_animation.value == 0) {
          print('time out');
          Provider.of<OTPProvider>(context, listen: false).setTimerDone(true);
        }
      });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isTimerRunning = true;
      }
    });
    startTimer();
  }

  @override
  void dispose() {
    pin2FocusNode.dispose();
    pin3FocusNode.dispose();
    pin4FocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void nextField({required String value, required FocusNode focusNode}) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  void startTimer() {
    if (!_isTimerRunning) {
      _controller.reset();
      _controller.forward();
      _isTimerRunning = true;
    }
  }

  void resetTimer() {
    _controller.reset();
    _isTimerRunning = false;
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.otpFormKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  controller: widget.pin1Controller,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 36),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: getProportionateScreenWidth(15)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                  ),
                  onChanged: (value) {
                    nextField(value: value, focusNode: pin2FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  controller: widget.pin2Controller,
                  focusNode: pin2FocusNode,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 36),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: getProportionateScreenWidth(15)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                  ),
                  onChanged: (value) {
                    nextField(value: value, focusNode: pin3FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  controller: widget.pin3Controller,
                  focusNode: pin3FocusNode,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 36),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: getProportionateScreenWidth(15)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                  ),
                  onChanged: (value) {
                    nextField(value: value, focusNode: pin4FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: getProportionateScreenWidth(60),
                child: TextFormField(
                  controller: widget.pin4Controller,
                  focusNode: pin4FocusNode,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 36),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: getProportionateScreenWidth(15)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xFF757575)),
                    ),
                  ),
                  onChanged: (value) {
                    pin4FocusNode.unfocus();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: getProportionateScreenHeight(20),
          ),
          timer(),
          SizedBox(height: SizeConfig.screenHeight * 0.15),
          CustomButton(
              text: 'Continue',
              btnColor: const Color(0xFF00A86B),
              textColor: Colors.white,
              onTap: () {
                // validate all the controller and key
                if (widget.otpFormKey.currentState!.validate()) {
                  // take all 4 OTP to the backend
                  // use if else condition, if timer expired, straight send
                  // the message
                  // else, normal use the resetValidOTP()
                  if (Provider.of<OTPProvider>(context, listen: false)
                          .timerDone ==
                      false) {
                    print('god damn');
                    resetValidOTP();
                  } else {
                    showSnackBar(context, 'OTP code has expired!');
                    print('timer done for continue');
                  }
                }
              }),
          SizedBox(height: getProportionateScreenHeight(150)),
          resendBtn(),
        ],
      ),
    );
  }

  Row timer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
              text: 'This code will be expired in ',
              style: GlobalVariables().subtextStyle,
              children: <TextSpan>[
                TextSpan(
                    text: '${_animation.value}',
                    style: TextStyle(color: Color(0xFF69BB01)))
              ]),
          // TweenAnimationBuilder(
          //   tween: Tween(begin: 30.0, end: 0),
          //   duration: Duration(seconds: 30),
          //   builder: (context, value, child) => Text(
          //     "00:${value.toInt()}",
          //     style: TextStyle(color: Color(0xFF69BB01)),
          //   ),
          //   onEnd: () {
          //     // give a signal that the timer is done (for the resetValidOTP
          //     // condition)
          //     print('times out!');
          //     Provider.of<OTPProvider>(context, listen: false).setTimerDone(true);
          //   },
          // ),
        )
      ],
    );
  }

  // the resend button
  Container resendBtn() {
    return Container(
      child: GestureDetector(
        child: Text(
          'Resend OTP Code',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
        onTap: () {
          resetOTP();
          // reset the timer, and timerDone status
          resetTimer();
          Provider.of<OTPProvider>(context, listen: false).setTimerDone(false);
        },
      ),
    );
  }
}
