# Encrypt the web/index.html file
echo "Enter password for decryption:"
read -s password

cd ..
openssl aes-256-cbc -d -pbkdf2 -in web/index.html.enc -out web/index.html -k $password
openssl aes-256-cbc -d -pbkdf2 -in .env.enc -out .env -k $password

# Check if openssl command was successful
if [ $? -ne 0 ]; then
  echo "Decryption failed."
  exit 2
fi