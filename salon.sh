#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, What can I do for you?\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
# show available services
  SERVICES=$($PSQL "select service_id, name FROM services ORDER BY service_id")
  # if there is no service available
  if [[ -z $SERVICES ]]
  then
    echo "Sorry, we don't have any service right now"
  # case there it is, show them formated
  else
    echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  # get customer choice
  read SERVICE_ID_SELECTED
  # if the choice is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    # send to main menu
      MAIN_MENU "oops, that is invalid number! Please, select again."
    else
      VALID_SERVICE=$($PSQL "select service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      # if it is a number but not the valid ones
      if [[ -z $VALID_SERVICE ]]
      then
      # send to main menu
        MAIN_MENU "I could not find that service. What would you like today?"
      else
      # get customer phone number
        echo -e "\nWhat is your phone number?"
        read CUSTOMER_PHONE
        # check if is a new customer or not
        CUSTOMER_NAME=$($PSQL "select name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        # if is a new customer
          if [[ -z $CUSTOMER_NAME ]]
          then
          # get the name, phone and incluid it to the table with the selected service
          echo -e "\nI do not have a record for this phone number, what is your name?"
          read CUSTOMER_NAME
          CUSTOMER_INFO_INCLUSION=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          SERVICE_NAME=$($PSQL "select name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          # get the time the customer wants to appoint
          echo "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
          read SERVICE_TIME
          # update the appointment table 
          CUSTOMER_ID=$($PSQL "select customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
          APPOINTMENT_INCLUSION=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          echo -e "\nI have note down."
        # case is an old customer
        else
        # get the service name and ask for the time the customer wants to appoint
        SERVICE_NAME=$($PSQL "select name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        echo "What time would you like your service')?"
        read SERVICE_TIME
        # update the appointment table 
        CUSTOMER_ID=$($PSQL "select customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        APPOINTMENT_INCLUSION=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        echo -e "\nI have note down."
        fi
       fi
     fi
   fi
}

MAIN_MENU
