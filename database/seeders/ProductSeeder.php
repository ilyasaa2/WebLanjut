<?php

namespace Database\Seeders;

use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $products = [
            [
                'name' => 'Produk A',
                'price' => 25000,
                'stock' => 20,
                'description' => 'Produk A - Perlengkapan Komputer',
            ],
            [
                'name' => 'Produk B',
                'price' => 50000,
                'stock' => 15,
                'description' => 'Produk B - Mouse Wireless Ergonomis',
            ],
            [
                'name' => 'Produk C',
                'price' => 75000,
                'stock' => 30,
                'description' => 'Produk C - Keyboard Mechanical RGB',
            ],
            [
                'name' => 'Produk D',
                'price' => 120000,
                'stock' => 10,
                'description' => 'Produk D - Headset Stereo Gaming',
            ],
        ];

        foreach ($products as $product) {
            Product::create($product);
        }
    }
}
