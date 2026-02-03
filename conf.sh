#!/bin/bash

source data/ip.txt
source data/domain.txt
source data/dir.txt

banner() {
    clear
    
    # ambil lebar terminal
    COLUMNS=$(tput cols)
    
    center_text() {
        local text="$1"
        local width=${#text}
        local pad=$(( (COLUMNS - width) / 2 ))
        printf "%*s%s\n" $pad "" "$text"
    }
    
    # tampilkan ASCII art (pakai center per baris)
    ascii_art="
░██╗░░░░░░░██╗███████╗██████╗░░░░░░░░░█████╗░░█████╗░███╗░░██╗███████╗██╗░██████╗░░
░██║░░██╗░░██║██╔════╝██╔══██╗░░░░░░░██╔══██╗██╔══██╗████╗░██║██╔════╝██║██╔════╝░░
░╚██╗████╗██╔╝█████╗░░██████╦╝░░░░░░░██║░░╚═╝██║░░██║██╔██╗██║█████╗░░██║██║░░██╗░░
░░████╔═████║░██╔══╝░░██╔══██╗░░░░░░░██║░░██╗██║░░██║██║╚████║██╔══╝░░██║██║░░╚██╗░
░░╚██╔╝░╚██╔╝░███████╗██████╦╝░░░░░░░╚█████╔╝╚█████╔╝██║░╚███║██║░░░░░██║╚██████╔╝░
░░░╚═╝░░░╚═╝░░╚══════╝╚═════╝░░░░░░░░░╚════╝░░╚════╝░╚═╝░░╚══╝╚═╝░░░░░╚═╝░╚═════╝░░
    "
    
    while IFS= read -r line; do
        center_text "$line"
    done <<< "$ascii_art"
    
    echo ""
    
    center_text "[==========================| By Ahmad Syarifudin Yusuf |==========================]"
    center_text "[Github]~> https://github.com/ASyusuff                                             "
    echo ""
    # array quotes
    tips=(
    "Gunakan 'sudo systemctl status apache2' untuk memastikan web servermu aktif."
    "Sebelum mengedit file konfigurasi, selalu buat backup dengan 'cp file.conf file.conf.bak'."
    "Gunakan 'sudo netstat -tuln | grep 80' untuk mengecek apakah port Apache terbuka."
    "Folder default web Apache ada di /var/www/html — jangan lupa ubah permission-nya dengan hati-hati."
    "Gunakan 'mysql_secure_installation' untuk mengamankan instalasi MySQL-mu."
    "Cek versi PHP dengan 'php -v' untuk memastikan kompatibilitas script."
    "Gunakan 'sudo tail -f /var/log/apache2/error.log' untuk memantau error web server secara langsung."
    "Ingin test koneksi database? Gunakan 'mysql -u root -p -e \"SHOW DATABASES;\"'"
    "Gunakan 'sudo systemctl restart apache2' setiap kali selesai mengubah konfigurasi."
    "Pastikan modul PHP aktif dengan perintah 'php -m | grep mysqli'."
    "Gunakan 'sudo a2enmod rewrite' untuk mengaktifkan mod_rewrite (penting buat .htaccess)."
    "File konfigurasi virtual host Apache ada di /etc/apache2/sites-available."
    "Gunakan 'sudo apache2ctl configtest' sebelum restart Apache untuk cek kesalahan konfigurasi."
    "Simpan password MySQL di file .env atau config yang tidak diakses publik."
    "Gunakan 'sudo chmod -R 755 /var/www/html' untuk mengatur izin file web dengan aman."
    "Gunakan 'php -S localhost:8080' untuk server lokal cepat tanpa Apache."
    "Gunakan 'systemctl enable apache2' agar Apache otomatis jalan saat boot."
    "Gunakan 'sudo service mysql status' untuk memastikan MySQL aktif."
    "Selalu periksa error PHP di /var/log/php/error.log jika halaman kosong."
    "Gunakan 'sudo apt autoremove' untuk membersihkan paket tak terpakai setelah update server."
    )
    
    # ambil random
    rand=$((RANDOM % ${#tips[@]}))
    center_text "${tips[$rand]}"
}

input_ip(){
    #input data user
    read -p "Masukan ip address untuk web server: " ip_address

    #pengolahan data user yang di input
    IFS='.' read -r octet1 octet2 octet3 octet4 <<< "$ip_address"

    cat >data/ip.txt << EOF
ip_address=$ip_address
octet1=$octet1
octet2=$octet2
octet3=$octet3
octet4=$octet4
EOF
}

input_domain() {

    read -p "Masukan nama domain utama untuk web: " main_domain
    read -p "Masukan nama sub-domain untuk web: " sub_domain

    #pengolahan data user yang di input
    IFS='.' read -r sub_domain1 root_domain1  <<< "$main_domain"
    IFS='.' read -r sub_domain2 root_domain2  <<< "$sub_domain"

    cat >data/domain.txt << EOF
main_domain=$main_domain
sub_domain=$sub_domain
root_domain1=$root_domain1
root_domain2=$root_domain2
sub_domain1=$sub_domain1
sub_domain2=$sub_domain2
EOF
}

input_dir() {

    read -p "Masukan nama direktori untuk domain utama: " DR1
    read -p "Masukan nama direktori untuk sub-domain: " DR2

    cat >data/dir.txt << EOF
DR1=$DR1
DR2=$DR2
EOF
}

apache_setup() {

    #updating
    echo "MENGECEK UPDATE..."
    #apt update && upgrade -y

    #installing apache2
    echo "MENGINSTAL APACHE2..."
    apt install apache2 -y

    #apache2 config | membuat halaman web
    echo "MENGKONFIGURASI APACHE2..."
    cd /var/www/
    mkdir $DR1

    cat <<EOF > /var/www/$DR1/index.html
<html>
helo
</html>
EOF


#apache2 config | membuat virtual host port
    cat > /etc/apache2/sites-available/$DR1.conf << EOF
<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
	ServerName $main_domain
	ServerAlias $root_domain1
	ServerAdmin webmaster@$root_domain1
	DocumentRoot /var/www/$DR1

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>
EOF
    
    cat > /etc/apache2/sites-available/$DR2.conf << EOF
<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
	ServerName $sub_domain
	ServerAlias $root_domain2
	ServerAdmin webmaster@$root_domain2
	DocumentRoot /var/www/$DR2

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>
EOF

    #enableling virtual host | reloading apache2
    cd /etc/apache2/sites-available/
    a2dissite "000-default.conf"
    a2ensite "$DR1.conf"
    a2ensite "$DR2.conf"
    systemctl reload apache2.service
}

bind_setup() {
    #menginstall bind9
    echo "MENGINSTALL BIND9..."
    apt install bind9 -y

    #konfigurasi top level domain 
    cat > /etc/bind/named.conf.local << EOF
zone "$root_domain1" {
	type master;
	file "/etc/bind/forward";
};

zone "$octet3.$octet2.$octet1.in-addr.arpa" {
	type master;
	notify no;
	file "/etc/bind/reverse";
};

EOF

    #menyalin code forward & reverse
    cp /etc/bind/db.local /etc/bind/forward
    cp /etc/bind/db.127 /etc/bind/reverse

    #editing file forward
    dell_code1="@	IN	A	127.0.0.1"
    dell_code2="@	IN	AAAA	::1"

    sed -i "/$dell_code1/,/$dell_code2/d" "/etc/bind/forward"
    sed -i "s/localhost/$root_domain1/g" "/etc/bind/forward"
   

    line_forward="@	IN	NS	$root_domain1."

    sed -i "/$line_forward/a\\
@	IN	A	$ip_address\\
$sub_domain1	IN	A	$ip_address\\
$sub_domain2	IN	A	$ip_address
    " "/etc/bind/forward"


    #editing file reverse
    dell_code3="1.0.0	IN	PTR	localhost."

    sed -i "\|$dell_code3|d" "/etc/bind/reverse"
    sed -i "s/localhost/$root_domain1/g" "/etc/bind/reverse"

    line_reverse="@	IN	NS	$root_domain1".

    sed -i "/$line_reverse/a\\
$octet4	IN	PTR	$root_domain1.\\
$octet4	IN	PTR	$main_domain.\\
$octet4	IN	PTR	$sub_domain." /etc/bind/reverse

    #global firward options
    cat > /etc/bind/named.conf.options << EOF
options {
	directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0's placeholder.

	forwarders {
		8.8.8.8;
	};

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
	dnssec-validation no;

	listen-on-v6 { any; };
};
EOF

}

wordpress_install () {

    apt install apache2 mariadb php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip php-mysql -y

    apt install mariadb-server -y

    mysql_secure_installation <<EOF
cihuy
n
n
y
y
y
y
EOF

    echo "pw default = cihuy"
    echo "CREATE DATABASE [namaData];"
    echo "CREATE USER '[user]'@localhost' IDENTIFIED BY '[password]';"
    echo "GRANT ALL PRIVILEGES ON [namaData].* TO '[user]'@localhost';"
    echo "FLUSH PRIVILEGES;"
    mariadb


    wget https://wordpress.org/latest.tar.gz
    tar -xzvf latest.tar.gz
    mv wordpress /var/www/$DR2

}

view_data () {
    echo "ip = $ip_address" 
    echo "domain = $main_domain & $sub_domain"
    echo "dir = $DR1 & $DR2"    
}

while true; do
    banner
    echo "Pilih opsi konfigurasi:"
    echo "(1)> Konfigurasi IP, Domain, Apache, dan Bind9"  
    echo "(2)> Konfigurasi IP dan Bind9"
    echo "(3)> Konfigurasi Domain, Apache, dan Bind9"
    echo "(4)> Instalasi WordPress pada Sub-Domain"
    echo "(5)> Lihat data konfigurasi"
    echo "(q)> Keluar"
    read -p "Masukkan pilihan Anda: " opsi
    case $opsi in
        1)
            input_ip
            input_domain
            input_dir
            apache_setup
            bind_setup
            break
            ;;
        2)
            input_ip
            bind_setup
            break
            ;;
        3)
            input_domain
            apache_setup
            bind_setup
            break
            ;;
        4)
            wordpress_install
            break
            ;;
        5)
            view_data
            break
            ;;
        [qQ])
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done