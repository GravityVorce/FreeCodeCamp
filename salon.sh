#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ Vu's Nail Salon ~~~~~\n"
echo -e "Welcome to Vu's Nail Salon, How can I help you?\n"

SERVICE_MENU () 
{
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Get Services Menu
  SERVICE_MENU=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$SERVICE_MENU" | while read SERVICE_ID BAR NAME
  do
    # Format Service Menu
    echo "$SERVICE_ID) $NAME"
  done

  # Get Service ID
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_NAME=$(echo "$SERVICE_ID_SELECTED" | sed 's/\b./\u\0/')
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE name='$SERVICE_NAME'")
  else
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
  fi 

  # Service not found
  if [[ -z $SERVICE_ID ]]
  then
    # Send to service menu
    SERVICE_MENU "I could not find that service. What would you like today?"
  else
    # Get customer's info
    echo -e "\nWhats your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # If customer does not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # Get customer's name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

    # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    # Get Customer Id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Get time for Appointment
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/ //')."




  fi
}

SERVICE_MENU