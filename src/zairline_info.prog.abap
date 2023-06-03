REPORT zairline_info.
*********************************************************************************************
* Functional Code
*********************************************************************************************
CLASS zcl_airline_capacity DEFINITION.
  PUBLIC SECTION.
    METHODS:
      get_available_capacity
        IMPORTING
          iv_carrid                    TYPE s_carr_id
        RETURNING
          VALUE(rv_available_capacity) TYPE i,
      get_used_capacity
        IMPORTING
          iv_carrid               TYPE s_carr_id
        RETURNING
          VALUE(rv_used_capacity) TYPE i,
      get_total_capacity
        IMPORTING
          iv_carrid                TYPE s_carr_id
        RETURNING
          VALUE(rv_total_capacity) TYPE i.
ENDCLASS.

CLASS zcl_airline_capacity IMPLEMENTATION.
  METHOD get_available_capacity.
    SELECT SUM( seatsmax + seatsmax_b + seatsmax_f - seatsocc - seatsocc_b - seatsocc_f )
       INTO @rv_available_capacity
      FROM sflight
      WHERE carrid = @iv_carrid.
  ENDMETHOD.

  METHOD get_used_capacity.
    SELECT SUM( seatsocc + seatsocc_b + seatsocc_f )
      INTO @rv_used_capacity
      FROM sflight
      WHERE carrid = @iv_carrid.
  ENDMETHOD.

  METHOD get_total_capacity.
    SELECT SUM( seatsmax + seatsmax_b + seatsmax_f )
      INTO @rv_total_capacity
      FROM sflight
      WHERE carrid = @iv_carrid.
  ENDMETHOD.
ENDCLASS.

*********************************************************************************************
* Test Class
*********************************************************************************************
CLASS ltc_airline_capacity_tests DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    DATA: lo_airline_capacity TYPE REF TO zcl_airline_capacity.

    METHODS:
      setup,
      test_get_available_capacity FOR TESTING,
      test_get_used_capacity FOR TESTING,
      test_get_total_capacity FOR TESTING,
      test_capacity_relationship FOR TESTING.
ENDCLASS.

CLASS ltc_airline_capacity_tests IMPLEMENTATION.
  METHOD setup.
    CREATE OBJECT lo_airline_capacity.
  ENDMETHOD.

  METHOD test_get_available_capacity.
    DATA: lv_available_capacity TYPE i.

    lv_available_capacity = lo_airline_capacity->get_available_capacity( iv_carrid = 'AA' ).

    cl_abap_unit_assert=>assert_not_initial(
      act = lv_available_capacity
      msg = 'Available capacity for the airline should not be initial'
    ).
  ENDMETHOD.

  METHOD test_get_used_capacity.
    DATA: lv_used_capacity TYPE i.

    lv_used_capacity = lo_airline_capacity->get_used_capacity( iv_carrid = 'AA' ).

    cl_abap_unit_assert=>assert_not_initial(
      act = lv_used_capacity
      msg = 'Used capacity for the airline should not be initial'
    ).
  ENDMETHOD.

  METHOD test_get_total_capacity.
    DATA: lv_total_capacity TYPE i.

    lv_total_capacity = lo_airline_capacity->get_total_capacity( iv_carrid = 'AA' ).

    cl_abap_unit_assert=>assert_not_initial(
      act = lv_total_capacity
      msg = 'Total capacity for the airline should not be initial'
    ).
  ENDMETHOD.

  METHOD test_capacity_relationship.
    DATA: lv_total_capacity     TYPE i,
          lv_available_capacity TYPE i,
          lv_used_capacity      TYPE i.

    lv_total_capacity = lo_airline_capacity->get_total_capacity( iv_carrid = 'AA' ).
    lv_available_capacity = lo_airline_capacity->get_available_capacity( iv_carrid = 'AA' ).
    lv_used_capacity = lo_airline_capacity->get_used_capacity( iv_carrid = 'AA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_total_capacity
      exp = lv_available_capacity + lv_used_capacity
      msg = 'Total capacity should be equal to the sum of available and used capacity'
    ).
  ENDMETHOD.

ENDCLASS.

SELECTION-SCREEN BEGIN OF BLOCK sel1 WITH FRAME TITLE TEXT-001.
PARAMETERS: p_carrid TYPE s_carr_id OBLIGATORY LOWER CASE.
SELECTION-SCREEN END OF BLOCK sel1.

*********************************************************************************************
* Execute Code
*********************************************************************************************
START-OF-SELECTION.

  DATA: o_airline_capacity TYPE REF TO zcl_airline_capacity,
        available_capacity TYPE i,
        used_capacity      TYPE i,
        total_capacity     TYPE i.

  CREATE OBJECT o_airline_capacity.

  available_capacity = o_airline_capacity->get_available_capacity( p_carrid ).
  used_capacity = o_airline_capacity->get_used_capacity( p_carrid ).
  total_capacity = o_airline_capacity->get_total_capacity( p_carrid ).

  WRITE: / 'The available capacity for airline AA is:', available_capacity.
  WRITE: / 'The used capacity for airline AA is:     ', used_capacity.
  WRITE: / 'The total capacity for airline AA is:    ', total_capacity.
