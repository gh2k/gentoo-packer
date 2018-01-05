<?php

error_reporting(E_ALL);

function getCurl() {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
    return $ch;
}

function getContent($url) {
    $ch = getCurl();
    curl_setopt($ch, CURLOPT_URL, $url);
    $result = curl_exec($ch);
    curl_close($ch);
    return $result;
}

$u = $_GET['file'] == 'stage3' ? 'http://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/latest-stage3-amd64-systemd.txt' : 'http://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/latest-install-amd64-minimal.txt';

$location = explode(' ',explode("\n", getContent($u))[2])[0];
$location = "http://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/$location";

header("Location: $location");
