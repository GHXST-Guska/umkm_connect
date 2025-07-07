<?php

/**
 * Script sederhana untuk membuat APP_KEY yang valid
 * untuk Lumen atau Laravel.
 */

echo 'base64:'.base64_encode(random_bytes(32));