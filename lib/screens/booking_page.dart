import 'package:flutter/material.dart';
import 'package:flutter_doctor_app/Models/booking_datetime_converted.dart';
import 'package:flutter_doctor_app/components/button.dart';
import 'package:flutter_doctor_app/components/custom_appbar.dart';
import 'package:flutter_doctor_app/main.dart';
import 'package:flutter_doctor_app/providers/dio_provider.dart';
import 'package:flutter_doctor_app/utils/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State
<BookingPage> {
  
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  String? token; //obtener el token para insertar el booking date y tiempo en la base de datos

  Future<void> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
  }

  @override
  void initState() {
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final doctor = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: CustomAppbar(
        appTitle: '                Appointment',
        icon: const FaIcon(Icons.arrow_back_ios_new),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children:<Widget>[
                  _tableCalendar(),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                    child: Center(
                      child: Text(
                        'Select Consultation Time',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    )
                ],
              ),
            ),
            _isWeekend
              ? SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 30),
                  alignment: Alignment.center,
                  child: Text(
                    'Weekend is not available, please select another date',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      )
                    ),
                  ),
                )
              : SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index){
                  return InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        _timeSelected = true;
                      });
                    },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentIndex == index
                            ? Colors.white
                            : Colors.black
                          ),
                          borderRadius: BorderRadius.circular(15),
                          color: _currentIndex == index
                          ? Config.primaryColor
                          : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${index + 9}:00 ${index + 9 > 11 ? "PM" : "AM"}', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentIndex == index ? Colors.white : null,
                          )
                        ),
                      ),
                    );
                  },
                  childCount: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, childAspectRatio: 1.5),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 55),
                    child: Button(
                      width: double.infinity,
                      title: 'Make Appointment',
                      onPressed: () async{
                        //convertir date/day/time en string
                        final getDate = DateConverted.getDate(_currentDay);
                        final getDay = DateConverted.getDay(_currentDay.weekday);
                        final getTime = DateConverted.getTime(_currentIndex!);

                        //post usando dio
                        //Pasa todos los detalles juntos con doctor id y el token
                        final booking = await DioProvider().bookAppointment(getDate, getDay, getTime, doctor['doctor_id'], token!);

                        //Si la reservación retorna el código 200 entonces redirecciona al success booking page
                        if(booking == 200) {
                          MyApp.navigatorKey.currentState!.pushNamed('success_booking');
                        }


                      },
                      disable: _timeSelected && _dateSelected ? false : true,
                    ),
                  ),
                )
          ]
        ),
      )
      
    );
    
  }
  
  Widget _tableCalendar(){
    return TableCalendar(
      focusedDay: _focusDay ,
      firstDay: DateTime.now(),
      lastDay: DateTime(2025, 6, 16),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Config.primaryColor,
          shape: BoxShape.circle
        )
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged:(format) {
        setState(() {
          _format = format;
        },
      );},
      onDaySelected: ((selectedDay, focusedDay){
        setState(() {
          _focusDay = focusedDay;
          _currentDay = selectedDay;
          _dateSelected = true;

          //checa si es fin de semana
          if(selectedDay.weekday == 6 || selectedDay.weekday == 7){
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex= null;
          } else {
            _isWeekend = false;
          }

        });
      }),
    );
  }
}

