<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    /**
     * Display a listing of the resource.
     * GET /api/products
     */
    public function index(): JsonResponse
    {
        $products = Product::latest()->get();
        return response()->json($products, 200);
    }

    /**
     * Store a newly created resource in storage.
     * POST /api/products
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'description' => 'nullable|string',
            'stock' => 'nullable|integer|min:0',
        ], [
            'name.required' => 'The name field is required.',
            'price.required' => 'The price field is required.',
            'price.numeric' => 'The price field must be a number.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'The given data was invalid.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $product = Product::create([
            'name' => $request->input('name'),
            'price' => $request->input('price'),
            'description' => $request->input('description'),
            'stock' => $request->input('stock', 0),
        ]);

        return response()->json($product, 201);
    }

    /**
     * Display the specified resource.
     * GET /api/products/{id}
     */
    public function show(string $id): JsonResponse
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'message' => 'Data produk dengan ID ' . $id . ' tidak ditemukan.',
            ], 404);
        }

        return response()->json($product, 200);
    }

    /**
     * Update the specified resource in storage.
     * PUT/PATCH /api/products/{id}
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'message' => 'Data produk dengan ID ' . $id . ' tidak ditemukan.',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'price' => 'sometimes|required|numeric|min:0',
            'description' => 'nullable|string',
            'stock' => 'nullable|integer|min:0',
        ], [
            'name.required' => 'The name field is required.',
            'price.required' => 'The price field is required.',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'The given data was invalid.',
                'errors' => $validator->errors(),
            ], 422);
        }

        $product->update($request->only(['name', 'price', 'description', 'stock']));

        return response()->json($product, 200);
    }

    /**
     * Remove the specified resource from storage.
     * DELETE /api/products/{id}
     */
    public function destroy(string $id): JsonResponse
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'message' => 'Data produk dengan ID ' . $id . ' tidak ditemukan.',
            ], 404);
        }

        $product->delete();

        return response()->json([
            'message' => 'Data produk berhasil dihapus.',
        ], 200);
    }
}
