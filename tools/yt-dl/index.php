<?php
header('Content-Type: application/json');

define('YTDLP',     '/usr/local/bin/yt-dlp');
define('CACHE_DIR', __DIR__ . '/cache');

// using a separate cache folder than the index file is good for tidiness
// this index.php file, in this example, should be located at your-website-url.com/api
define('CACHE_URL', 'https://your-website-url.com/api/cache');
$url = $_GET['url'] ?? '';

if (!$url) {
    http_response_code(400);
    echo json_encode(['error' => 'no url']);
    exit;
}

if (!preg_match('#^https?://#i', $url)) {
    http_response_code(400);
    echo json_encode(['error' => 'must use http or https']);
    exit;
}

// dont rely on this, you may still need to fix permissions depending on your setup. www-data my beloathed
if (!is_dir(CACHE_DIR)) {
    mkdir(CACHE_DIR, 0755, true);
}

$escaped = escapeshellarg($url);
$cookies = __DIR__ . '/youtube_cookies.txt'; // use any number of browser plugins to get a cookies file. i used a firefox one called 'cookies.txt'. goes in the same folder as index.php
$cookies_arg = file_exists($cookies) ? '--cookies ' . escapeshellarg($cookies) : '';
$meta_json = shell_exec(YTDLP . " $cookies_arg --dump-single-json --no-playlist -- $escaped 2>/tmp/errorrr.log"); // 'cat /tmp/errorrr.log' on linux. just incase you need it

if (!$meta_json) {
    http_response_code(500);
    echo json_encode(['error' => 'yt-dlp returned nothing']);
    exit;
}

$meta = json_decode($meta_json, true);

if (!$meta || empty($meta['id'])) {
    http_response_code(500);
    echo json_encode(['error' => 'dont know what the hell it gave us']);
    exit;
}

$id       = preg_replace('/[^a-zA-Z0-9_\-]/', '', $meta['id']);
$filename = $id . '.mp3'; // OGGs are smaller but sound like garbage. YMMV
$filepath = CACHE_DIR . '/' . $filename;
$file_url = CACHE_URL . '/' . $filename;

if (!file_exists($filepath)) {
    $out_template = escapeshellarg(CACHE_DIR . '/%(id)s.%(ext)s');
    shell_exec(YTDLP . " $cookies_arg --geo-bypass --extract-audio --audio-format mp3 --audio-quality 0 --no-playlist --output $out_template -- $escaped 2>/tmp/ytdlp_error.log");

    if (!file_exists($filepath)) {
        http_response_code(500);
        echo json_encode(['error' => 'download failed. file was probably gigantic.']);
        exit;
    }
}

// most youtube URLs have the artist name in the title, so the artist field is mostly useless here
echo json_encode([
    'url'         => $file_url,
    'title'       => $meta['title']       ?? 'Unknown',
    'artist'      => $meta['artist']      ?? 'Unknown',
    'album'       => $meta['album']       ?? 'Unknown',
    'duration'    => $meta['duration']    ?? 0,
    'webpage_url' => $meta['webpage_url'] ?? $url,
    'upload_date' => $meta['upload_date'] ?? '',
]);
