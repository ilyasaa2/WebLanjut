<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProductController;

Route::get('/', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'Backend Laravel REST API is active',
        'version' => '1.0.0',
        'endpoints' => [
            'GET /api/products' => 'Menampilkan seluruh data produk',
            'GET /api/products/{id}' => 'Menampilkan detail produk berdasarkan ID',
            'POST /api/products' => 'Menambahkan data produk baru',
            'PUT /api/products/{id}' => 'Mengubah data produk',
            'DELETE /api/products/{id}' => 'Menghapus data produk',
        ]
    ]);
});

Route::apiResource('products', ProductController::class);
