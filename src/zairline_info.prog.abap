REPORT zairline_info.

*********************************************************************************************
* Functional code
*********************************************************************************************
TYPES: BEGIN OF s_sflight,
         mandt      TYPE s_mandt,
         carrid     TYPE s_carr_id,
         connid     TYPE s_conn_id,
         fldate     TYPE s_date,
         price      TYPE s_price,
         currency   TYPE s_currcode,
         planetype  TYPE s_planetye,
         seatsmax   TYPE s_seatsmax,
         seatsocc   TYPE s_seatsocc,
         paymentsum TYPE s_sum,
         seatsmax_b TYPE s_smax_b,
         seatsocc_b TYPE s_socc_b,
         seatsmax_f TYPE s_smax_f,
         seatsocc_f TYPE s_socc_f,
       END OF s_sflight.

TYPES: t_sflight TYPE TABLE OF s_sflight.

INTERFACE zif_airline_capacity.
  METHODS:
    get_data
      IMPORTING
        iv_carrid TYPE s_sflight-carrid,
    get_available_capacity
      RETURNING
        VALUE(rv_available_capacity) TYPE i,
    get_used_capacity
      RETURNING
        VALUE(rv_used_capacity) TYPE i,
    get_total_capacity
      RETURNING
        VALUE(rv_total_capacity) TYPE i.
ENDINTERFACE.

CLASS zcl_airline_capacity DEFINITION.
  PUBLIC SECTION.
    INTERFACES: zif_airline_capacity.
  PROTECTED SECTION.
    DATA: lt_sflight_data TYPE t_sflight,
          ls_sflight_data TYPE s_sflight.
ENDCLASS.

CLASS zcl_airline_capacity IMPLEMENTATION.
  METHOD zif_airline_capacity~get_data.
    SELECT *
      INTO TABLE @lt_sflight_data
      FROM sflight
      WHERE carrid = @iv_carrid.
  ENDMETHOD.

  METHOD zif_airline_capacity~get_available_capacity.
    LOOP AT lt_sflight_data INTO ls_sflight_data.
      rv_available_capacity = rv_available_capacity + ( ls_sflight_data-seatsmax + ls_sflight_data-seatsmax_b + ls_sflight_data-seatsmax_f - ls_sflight_data-seatsocc - ls_sflight_data-seatsocc_b - ls_sflight_data-seatsocc_f ).
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_airline_capacity~get_used_capacity.
    LOOP AT lt_sflight_data INTO ls_sflight_data.
      rv_used_capacity = rv_used_capacity + ( ls_sflight_data-seatsocc + ls_sflight_data-seatsocc_b + ls_sflight_data-seatsocc_f ).
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_airline_capacity~get_total_capacity.
    LOOP AT lt_sflight_data INTO ls_sflight_data.
      rv_total_capacity = rv_total_capacity + ( ls_sflight_data-seatsmax + ls_sflight_data-seatsmax_b + ls_sflight_data-seatsmax_f ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

*********************************************************************************************
* Test double
*********************************************************************************************
CLASS zcl_airline_capacity_td DEFINITION INHERITING FROM zcl_airline_capacity.
  PUBLIC SECTION.
    METHODS zif_airline_capacity~get_data REDEFINITION.
ENDCLASS.

CLASS zcl_airline_capacity_td IMPLEMENTATION.
  METHOD zif_airline_capacity~get_data.
    ls_sflight_data = VALUE #( mandt = 800 carrid = 'AA' connid = 2402 fldate = '20230601' price = 300 currency = 'USD'
                               planetype = '747-400' seatsmax = 400 seatsocc = 200 paymentsum = 30000 seatsmax_b = 80 seatsocc_b = 40
                               seatsmax_f = 70 seatsocc_f = 35 ).
    INSERT ls_sflight_data INTO TABLE lt_sflight_data.
    ls_sflight_data = VALUE #( mandt = 800 carrid = 'AA' connid = 2401 fldate = '20230602' price = 250 currency = 'USD'
                               planetype = '747-400' seatsmax = 400 seatsocc = 150 paymentsum = 25000 seatsmax_b = 80 seatsocc_b = 30
                               seatsmax_f = 70 seatsocc_f = 30 ).
    INSERT ls_sflight_data INTO TABLE lt_sflight_data.
  ENDMETHOD.

ENDCLASS.

*********************************************************************************************
* Unit tests
*********************************************************************************************
CLASS ltc_airline_capacity_tests DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    DATA: mo_airline_capacity TYPE REF TO zcl_airline_capacity_td.

    METHODS:
      setup,
      test_get_available_capacity FOR TESTING,
      test_get_used_capacity FOR TESTING,
      test_get_total_capacity FOR TESTING.
ENDCLASS.

CLASS ltc_airline_capacity_tests IMPLEMENTATION.
  METHOD setup.
    CREATE OBJECT mo_airline_capacity TYPE zcl_airline_capacity_td.
    mo_airline_capacity->zif_airline_capacity~get_data( 'AA' ).

  ENDMETHOD.

  METHOD test_get_available_capacity.
    DATA: lv_available_capacity TYPE i.

    lv_available_capacity = mo_airline_capacity->zif_airline_capacity~get_available_capacity( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_available_capacity
      exp = 615
      msg = 'Available capacity is not correct'
    ).

  ENDMETHOD.

  METHOD test_get_used_capacity.
    DATA: lv_used_capacity TYPE i.

    lv_used_capacity = mo_airline_capacity->zif_airline_capacity~get_used_capacity( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_used_capacity
      exp = 485
      msg = 'Used capacity is not correct'
    ).

  ENDMETHOD.

  METHOD test_get_total_capacity.
    DATA: lv_total_capacity TYPE i.

    lv_total_capacity = mo_airline_capacity->zif_airline_capacity~get_total_capacity( ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_total_capacity
      exp = 1100
      msg = 'Total capacity is not correct'
    ).

  ENDMETHOD.
ENDCLASS.

*********************************************************************************************
* Execute dode
*********************************************************************************************
START-OF-SELECTION.

  DATA: lo_airline_capacity TYPE REF TO zcl_airline_capacity,
        available_capacity  TYPE i,
        used_capacity       TYPE i,
        total_capacity      TYPE i.

  CREATE OBJECT lo_airline_capacity.
  lo_airline_capacity->zif_airline_capacity~get_data( 'AA' ).

  available_capacity = lo_airline_capacity->zif_airline_capacity~get_available_capacity( ).
  used_capacity = lo_airline_capacity->zif_airline_capacity~get_used_capacity( ).
  total_capacity = lo_airline_capacity->zif_airline_capacity~get_total_capacity( ).

  WRITE: / 'The available capacity for airline AA is:', available_capacity.
  WRITE: / 'The used capacity for airline AA is:     ', used_capacity.
  WRITE: / 'The total capacity for airline AA is:    ', total_capacity.
