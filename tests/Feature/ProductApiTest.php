<?php

namespace Tests\Feature;

use App\Models\Product;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ProductApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Seed initial data
        Product::create([
            'name' => 'Produk A',
            'price' => 25000,
            'stock' => 10,
            'description' => 'Test Deskripsi'
        ]);
    }

    /**
     * Skenario 1: GET /api/products (Menampilkan seluruh data)
     */
    public function test_can_list_all_products(): void
    {
        $response = $this->getJson('/api/products');

        $response->assertStatus(200)
            ->assertJsonIsArray()
            ->assertJsonFragment([
                'name' => 'Produk A',
                'price' => 25000,
            ]);
    }

    /**
     * Skenario 2: GET /api/products/{id} (Menampilkan detail data)
     */
    public function test_can_show_product_detail(): void
    {
        $response = $this->getJson('/api/products/1');

        $response->assertStatus(200)
            ->assertJson([
                'id' => 1,
                'name' => 'Produk A',
                'price' => 25000,
            ]);
    }

    /**
     * Skenario Tambahan: GET /api/products/9999 (ID tidak ditemukan)
     */
    public function test_show_product_not_found(): void
    {
        $response = $this->getJson('/api/products/9999');

        $response->assertStatus(404)
            ->assertJsonStructure(['message']);
    }

    /**
     * Skenario 3: POST /api/products (Data valid)
     */
    public function test_can_create_product_with_valid_data(): void
    {
        $payload = [
            'name' => 'Produk Baru',
            'price' => 30000,
            'stock' => 5,
            'description' => 'Produk Baru Deskripsi'
        ];

        $response = $this->postJson('/api/products', $payload);

        $response->assertStatus(201)
            ->assertJsonFragment([
                'name' => 'Produk Baru',
                'price' => 30000,
            ]);

        $this->assertDatabaseHas('products', [
            'name' => 'Produk Baru',
        ]);
    }

    /**
     * Skenario 4: POST /api/products (Data tidak valid / Validasi)
     */
    public function test_cannot_create_product_with_invalid_data(): void
    {
        $payload = [
            'name' => '', // kosong
        ];

        $response = $this->postJson('/api/products', $payload);

        $response->assertStatus(422)
            ->assertJsonStructure([
                'message',
                'errors' => [
                    'name',
                    'price'
                ]
            ]);
    }

    /**
     * Skenario 5: PUT /api/products/{id} (Update data)
     */
    public function test_can_update_product(): void
    {
        $payload = [
            'name' => 'Produk Update',
            'price' => 35000,
        ];

        $response = $this->putJson('/api/products/1', $payload);

        $response->assertStatus(200)
            ->assertJsonFragment([
                'name' => 'Produk Update',
                'price' => 35000,
            ]);

        $this->assertDatabaseHas('products', [
            'id' => 1,
            'name' => 'Produk Update',
        ]);
    }

    /**
     * Skenario 6: DELETE /api/products/{id} (Hapus data)
     */
    public function test_can_delete_product(): void
    {
        $response = $this->deleteJson('/api/products/1');

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Data produk berhasil dihapus.'
            ]);

        $this->assertDatabaseMissing('products', [
            'id' => 1,
        ]);
    }
}
