<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Warung Sambal Samuda Nusantara - SCM & Surat Jalan</title>
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Alpine.js -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Firebase SDK (Compat / Modular via CDN) -->
    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
        import { getFirestore, collection, getDocs, addDoc, updateDoc, deleteDoc, doc, setDoc, onSnapshot } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

        const firebaseConfig = {
            apiKey: "AIzaSyAnBOXgNjVX12NLPQYOdgolEfYhQ4p71mA",
            authDomain: "scm-sambal-samuda.firebaseapp.com",
            projectId: "scm-sambal-samuda",
            storageBucket: "scm-sambal-samuda.firebasestorage.app",
            messagingSenderId: "594111914108",
            appId: "1:594111914108:web:5d788784d47d59580a69f9",
            measurementId: "G-J8W03WFL6Q"
        };

        const app = initializeApp(firebaseConfig);
        const db = getFirestore(app);

        window.db = db;
        window.firebaseModules = { collection, getDocs, addDoc, updateDoc, deleteDoc, doc, setDoc, onSnapshot };
        window.dispatchEvent(new Event('firebase-ready'));
    </script>

    <style>
        @media print {
            body * {
                visibility: hidden;
            }
            #printable-area, #printable-area * {
                visibility: visible;
            }
            #printable-area {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                margin: 0;
                padding: 20px;
                background: white;
            }
            .no-print {
                display: none !important;
            }
        }
    </style>
</head>
<body class="bg-slate-100 text-slate-800 font-sans antialiased" x-data="scmApp()">

    <!-- TOP BAR / ROLE SWITCHER -->
    <header class="bg-red-800 text-white shadow-md sticky top-0 z-50 no-print">
        <div class="max-w-7xl mx-auto px-4 py-3 flex flex-col md:flex-row justify-between items-center gap-3">
            <div class="flex items-center space-x-3">
                <div class="bg-white text-red-800 p-2 rounded-lg font-black text-xl shadow">
                    <i class="fa-solid fa-pepper-hot"></i>
                </div>
                <div>
                    <h1 class="font-bold text-lg leading-tight">Warung Sambal Samuda Nusantara</h1>
                    <p class="text-xs text-red-200">Sistem Supply Chain, PO & Surat Jalan (Firebase Connected)</p>
                </div>
            </div>

            <!-- Role Selector -->
            <div class="flex items-center space-x-2 bg-red-900/60 p-1.5 rounded-lg border border-red-700">
                <span class="text-xs font-semibold px-2 text-red-200"><i class="fa-solid fa-user-shield mr-1"></i> Role:</span>
                <template x-for="r in roles" :key="r.id">
                    <button @click="currentRole = r.id"
                        :class="currentRole === r.id ? 'bg-white text-red-800 font-bold shadow' : 'text-white hover:bg-red-700/50'"
                        class="px-3 py-1.5 rounded text-xs transition duration-150"
                        x-text="r.name">
                    </button>
                </template>
            </div>
        </div>
    </header>

    <!-- MAIN CONTAINER -->
    <main class="max-w-7xl mx-auto px-4 py-6">

        <!-- NOTIFICATION TOAST -->
        <div x-show="notification.show" 
             x-transition 
             class="mb-6 p-4 rounded-xl shadow-lg border flex items-center justify-between no-print"
             :class="notification.type === 'success' ? 'bg-emerald-50 border-emerald-200 text-emerald-800' : 'bg-red-50 border-red-200 text-red-800'">
            <div class="flex items-center space-x-3">
                <i :class="notification.type === 'success' ? 'fa-solid fa-circle-check text-emerald-600' : 'fa-solid fa-triangle-exclamation text-red-600'" class="text-xl"></i>
                <span class="font-medium text-sm" x-text="notification.message"></span>
            </div>
            <button @click="notification.show = false" class="text-slate-400 hover:text-slate-600 font-bold">&times;</button>
        </div>

        <!-- ================= VIEW 1: RESTO OUTLET ================= -->
        <div x-show="currentRole === 'resto'" class="space-y-6">
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-white p-5 rounded-2xl shadow-sm border border-slate-200">
                <div>
                    <h2 class="text-xl font-bold text-slate-800"><i class="fa-solid fa-store text-red-600 mr-2"></i> Dashboard Outlet Resto</h2>
                    <p class="text-sm text-slate-500">Kelola pemesanan bahan baku (PO) ke Central Kitchen & konfirmasi penerimaan barang.</p>
                </div>
                <button @click="openPoModal = true" class="bg-red-600 hover:bg-red-700 text-white px-4 py-2.5 rounded-xl font-medium text-sm shadow transition flex items-center gap-2">
                    <i class="fa-solid fa-plus"></i> Buat PO Baru
                </button>
            </div>

            <!-- Daftar PO Resto -->
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="p-5 border-b border-slate-100 flex justify-between items-center">
                    <h3 class="font-bold text-slate-800">Daftar Purchase Order (PO) Outlet</h3>
                    <span class="text-xs bg-slate-100 text-slate-600 px-3 py-1 rounded-full font-medium" x-text="poList.length + ' Total PO'"></span>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse text-sm">
                        <thead>
                            <tr class="bg-slate-50 text-slate-600 font-semibold border-b border-slate-200">
                                <th class="p-4">No. PO</th>
                                <th class="p-4">Outlet</th>
                                <th class="p-4">Target Kirim</th>
                                <th class="p-4">Status</th>
                                <th class="p-4 text-center">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <template x-for="po in poList" :key="po.id">
                                <tr class="hover:bg-slate-50">
                                    <td class="p-4 font-bold text-red-700" x-text="po.poNumber"></td>
                                    <td class="p-4" x-text="po.outletName"></td>
                                    <td class="p-4" x-text="po.targetDate"></td>
                                    <td class="p-4">
                                        <span class="px-3 py-1 rounded-full text-xs font-semibold"
                                            :class="{
                                                'bg-amber-100 text-amber-800': po.status === 'Pending',
                                                'bg-blue-100 text-blue-800': po.status === 'Diproses CK',
                                                'bg-purple-100 text-purple-800': po.status === 'Dikirim',
                                                'bg-emerald-100 text-emerald-800': po.status === 'Diterima Outlet',
                                                'bg-rose-100 text-rose-800': po.status === 'Ditolak'
                                            }" x-text="po.status">
                                        </span>
                                    </td>
                                    <td class="p-4 text-center space-x-2">
                                        <button @click="viewPoDetail(po)" class="bg-slate-100 hover:bg-slate-200 text-slate-700 px-3 py-1.5 rounded-lg text-xs font-medium transition">
                                            <i class="fa-solid fa-eye mr-1"></i> Detail
                                        </button>
                                        <button x-show="po.status === 'Dikirim'" @click="openReceiveModal(po)" class="bg-emerald-600 hover:bg-emerald-700 text-white px-3 py-1.5 rounded-lg text-xs font-medium transition">
                                            <i class="fa-solid fa-box-open mr-1"></i> Terima Barang
                                        </button>
                                    </td>
                                </tr>
                            </template>
                            <template x-if="poList.length === 0">
                                <tr>
                                    <td colspan="5" class="p-8 text-center text-slate-400">Belum ada data Purchase Order.</td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ================= VIEW 2: CENTRAL KITCHEN ================= -->
        <div x-show="currentRole === 'ck'" class="space-y-6">
            <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                    <h2 class="text-xl font-bold text-slate-800"><i class="fa-solid fa-warehouse text-red-600 mr-2"></i> Central Kitchen Control Center</h2>
                    <p class="text-sm text-slate-500">Validasi PO masuk, kelola stok gudang pusat, penerbitan surat jalan & mutasi.</p>
                </div>
                <div class="flex gap-2">
                    <button @click="activeCkTab = 'po'" :class="activeCkTab === 'po' ? 'bg-red-600 text-white' : 'bg-slate-100 text-slate-700'" class="px-4 py-2 rounded-xl text-xs font-bold transition">Validasi PO</button>
                    <button @click="activeCkTab = 'inventory'" :class="activeCkTab === 'inventory' ? 'bg-red-600 text-white' : 'bg-slate-100 text-slate-700'" class="px-4 py-2 rounded-xl text-xs font-bold transition">Stok & Katalog</button>
                </div>
            </div>

            <!-- TAB 1 CK: PO PROCESSING -->
            <div x-show="activeCkTab === 'po'" class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="p-5 border-b border-slate-100 flex justify-between items-center">
                    <h3 class="font-bold text-slate-800">Antrean PO Masuk dari Outlet</h3>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse text-sm">
                        <thead>
                            <tr class="bg-slate-50 text-slate-600 font-semibold border-b border-slate-200">
                                <th class="p-4">No. PO</th>
                                <th class="p-4">Outlet Pemesan</th>
                                <th class="p-4">Target Kirim</th>
                                <th class="p-4">Status</th>
                                <th class="p-4 text-center">Aksi / Proses</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <template x-for="po in poList" :key="po.id">
                                <tr class="hover:bg-slate-50">
                                    <td class="p-4 font-bold text-red-700" x-text="po.poNumber"></td>
                                    <td class="p-4" x-text="po.outletName"></td>
                                    <td class="p-4" x-text="po.targetDate"></td>
                                    <td class="p-4">
                                        <span class="px-3 py-1 rounded-full text-xs font-semibold"
                                            :class="{
                                                'bg-amber-100 text-amber-800': po.status === 'Pending',
                                                'bg-blue-100 text-blue-800': po.status === 'Diproses CK',
                                                'bg-purple-100 text-purple-800': po.status === 'Dikirim',
                                                'bg-emerald-100 text-emerald-800': po.status === 'Diterima Outlet'
                                            }" x-text="po.status">
                                        </span>
                                    </td>
                                    <td class="p-4 text-center space-x-2">
                                        <button x-show="po.status === 'Pending'" @click="openProcessModal(po)" class="bg-blue-600 hover:bg-blue-700 text-white px-3 py-1.5 rounded-lg text-xs font-medium transition">
                                            <i class="fa-solid fa-list-check mr-1"></i> Verifikasi & Edit Qty
                                        </button>
                                        <button x-show="po.status === 'Diproses CK'" @click="openDispatchModal(po)" class="bg-purple-600 hover:bg-purple-700 text-white px-3 py-1.5 rounded-lg text-xs font-medium transition">
                                            <i class="fa-solid fa-truck-fast mr-1"></i> Kirim & Surat Jalan
                                        </button>
                                        <button x-show="po.status !== 'Pending' && po.status !== 'Diproses CK'" @click="viewPoDetail(po)" class="bg-slate-100 hover:bg-slate-200 text-slate-700 px-3 py-1.5 rounded-lg text-xs font-medium transition">
                                            <i class="fa-solid fa-print mr-1"></i> Cetak Surat Jalan
                                        </button>
                                    </td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- TAB 2 CK: INVENTORY & CATEGORY -->
            <div x-show="activeCkTab === 'inventory'" class="space-y-6">
                <!-- Kategori & Tombol Tambah -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 md:col-span-2">
                        <div class="flex justify-between items-center mb-4">
                            <h3 class="font-bold text-slate-800">Manajemen Kategori Bahan Baku</h3>
                            <button @click="openCategoryModal = true" class="bg-slate-800 hover:bg-slate-900 text-white px-3 py-1.5 rounded-xl text-xs font-medium">
                                <i class="fa-solid fa-folder-plus mr-1"></i> Kelola Kategori
                            </button>
                        </div>
                        <div class="flex flex-wrap gap-2">
                            <template x-for="cat in categories" :key="cat">
                                <span class="bg-slate-100 text-slate-700 px-3 py-1 rounded-lg text-xs font-semibold" x-text="cat"></span>
                            </template>
                        </div>
                    </div>
                    <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200 flex flex-col justify-between">
                        <div>
                            <h3 class="font-bold text-slate-800 mb-1">Tambah Produk SKU</h3>
                            <p class="text-xs text-slate-500 mb-4">Tambah item baru ke gudang Central Kitchen.</p>
                        </div>
                        <button @click="openProductModal = true" class="bg-red-600 hover:bg-red-700 text-white w-full py-2.5 rounded-xl text-xs font-bold transition flex items-center justify-center gap-2">
                            <i class="fa-solid fa-plus-circle"></i> Tambah Item SKU
                        </button>
                    </div>
                </div>

                <!-- Tabel Stok SKU -->
                <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                    <div class="p-5 border-b border-slate-100 flex justify-between items-center">
                        <h3 class="font-bold text-slate-800">Stok Ready Central Kitchen</h3>
                        <span class="text-xs bg-slate-100 text-slate-600 px-3 py-1 rounded-full font-medium" x-text="inventory.length + ' SKU Terdaftar'"></span>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-left border-collapse text-sm">
                            <thead>
                                <tr class="bg-slate-50 text-slate-600 font-semibold border-b border-slate-200">
                                    <th class="p-4">SKU / Nama Bahan</th>
                                    <th class="p-4">Kategori</th>
                                    <th class="p-4">Stok Ready</th>
                                    <th class="p-4">Buffer Min.</th>
                                    <th class="p-4">Status Stok</th>
                                    <th class="p-4 text-center">Aksi</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100">
                                <template x-for="item in inventory" :key="item.id">
                                    <tr class="hover:bg-slate-50">
                                        <td class="p-4 font-medium text-slate-800" x-text="item.name"></td>
                                        <td class="p-4 text-slate-500" x-text="item.category"></td>
                                        <td class="p-4 font-bold text-slate-800" x-text="item.stock + ' ' + item.unit"></td>
                                        <td class="p-4 text-slate-500" x-text="item.minBuffer + ' ' + item.unit"></td>
                                        <td class="p-4">
                                            <span class="px-2.5 py-1 rounded-full text-xs font-semibold"
                                                :class="{
                                                    'bg-emerald-100 text-emerald-800': item.stock > item.minBuffer,
                                                    'bg-amber-100 text-amber-800': item.stock <= item.minBuffer && item.stock > 0,
                                                    'bg-red-100 text-red-800': item.stock === 0
                                                }"
                                                x-text="item.stock > item.minBuffer ? 'Aman' : (item.stock > 0 ? 'Menipis' : 'Habis')">
                                            </span>
                                        </td>
                                        <td class="p-4 text-center space-x-2">
                                            <button @click="editProduct(item)" class="bg-slate-100 hover:bg-slate-200 text-slate-700 px-2.5 py-1 rounded text-xs font-medium">
                                                <i class="fa-solid fa-pen"></i> Edit
                                            </button>
                                            <button @click="deleteProduct(item.id)" class="bg-rose-50 hover:bg-rose-100 text-rose-600 px-2.5 py-1 rounded text-xs font-medium">
                                                <i class="fa-solid fa-trash"></i> Hapus
                                            </button>
                                        </td>
                                    </tr>
                                </template>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- ================= VIEW 3: AUDIT & LAPORAN (KARTU STOK) ================= -->
        <div x-show="currentRole === 'audit'" class="space-y-6">
            <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200">
                <h2 class="text-xl font-bold text-slate-800"><i class="fa-solid fa-chart-line text-red-600 mr-2"></i> Kartu Stok & Audit Mutasi</h2>
                <p class="text-sm text-slate-500">Riwayat pergerakan keluar masuk barang gudang Central Kitchen & outlet.</p>
            </div>
            <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                <div class="p-5 border-b border-slate-100">
                    <h3 class="font-bold text-slate-800">Log Mutasi Inventori</h3>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse text-sm">
                        <thead>
                            <tr class="bg-slate-50 text-slate-600 font-semibold border-b border-slate-200">
                                <th class="p-4">Waktu</th>
                                <th class="p-4">Jenis Mutasi</th>
                                <th class="p-4">Barang</th>
                                <th class="p-4">Jumlah</th>
                                <th class="p-4">Keterangan</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <template x-for="log in stockLogs" :key="log.id">
                                <tr class="hover:bg-slate-50">
                                    <td class="p-4 text-xs text-slate-500" x-text="log.timestamp"></td>
                                    <td class="p-4">
                                        <span class="px-2.5 py-1 rounded text-xs font-bold"
                                            :class="log.type === 'MASUK' ? 'bg-emerald-100 text-emerald-800' : 'bg-red-100 text-red-800'"
                                            x-text="log.type">
                                        </span>
                                    </td>
                                    <td class="p-4 font-medium text-slate-800" x-text="log.itemName"></td>
                                    <td class="p-4 font-bold" :class="log.type === 'MASUK' ? 'text-emerald-600' : 'text-red-600'" x-text="(log.type === 'MASUK' ? '+' : '-') + log.qty + ' ' + log.unit"></td>
                                    <td class="p-4 text-xs text-slate-600" x-text="log.notes"></td>
                                </tr>
                            </template>
                            <template x-if="stockLogs.length === 0">
                                <tr>
                                    <td colspan="5" class="p-8 text-center text-slate-400">Belum ada riwayat mutasi stok.</td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </main>

    <!-- ================= MODAL: BUAT PO BARU (RESTO) ================= -->
    <div x-show="openPoModal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-2xl w-full p-6 shadow-2xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center border-b pb-3">
                <h3 class="font-bold text-lg text-slate-800"><i class="fa-solid fa-cart-plus text-red-600 mr-2"></i> Buat Purchase Order (PO) Baru</h3>
                <button @click="openPoModal = false" class="text-slate-400 hover:text-slate-600 font-bold">&times;</button>
            </div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Pilih Outlet Resto</label>
                    <select x-model="newPo.outletName" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50 focus:ring-2 focus:ring-red-500">
                        <option value="Resto Samuda Pusat">Resto Samuda Pusat</option>
                        <option value="Resto Samuda Cabang 1">Resto Samuda Cabang 1</option>
                        <option value="Resto Samuda Cabang 2">Resto Samuda Cabang 2</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Target Tanggal Pengiriman</label>
                    <input type="date" x-model="newPo.targetDate" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50">
                </div>
            </div>

            <!-- Item PO -->
            <div>
                <label class="block text-xs font-semibold text-slate-600 mb-2">Daftar Bahan Baku Pesanan</label>
                <div class="space-y-2">
                    <template x-for="(item, index) in newPo.items" :key="index">
                        <div class="flex gap-2 items-center bg-slate-50 p-3 rounded-xl border border-slate-200">
                            <select x-model="item.itemId" @change="updateItemUnit(index)" class="flex-1 border rounded-lg p-2 text-xs bg-white">
                                <option value="">-- Pilih Bahan Baku SKU --</option>
                                <template x-for="inv in inventory" :key="inv.id">
                                    <option :value="inv.id" x-text="inv.name + ' (Stok Ready CK: ' + inv.stock + ' ' + inv.unit + ')'"></option>
                                </template>
                            </select>
                            <input type="number" min="1" x-model.number="item.qty" placeholder="Qty" class="w-20 border rounded-lg p-2 text-xs bg-white text-center">
                            <span class="text-xs font-semibold text-slate-600 w-16" x-text="item.unit"></span>
                            <button @click="newPo.items.splice(index, 1)" class="text-rose-600 hover:text-rose-800 px-2 font-bold">&times;</button>
                        </div>
                    </template>
                </div>
                <button @click="newPo.items.push({ itemId: '', qty: 1, unit: 'Kg' })" class="mt-3 text-xs font-bold text-red-600 hover:text-red-700 flex items-center gap-1">
                    <i class="fa-solid fa-plus"></i> Tambah Baris Bahan Baku
                </button>
            </div>

            <div>
                <label class="block text-xs font-semibold text-slate-600 mb-1">Catatan / Keterangan PO</label>
                <textarea x-model="newPo.notes" rows="2" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50" placeholder="Catatan khusus untuk Central Kitchen..."></textarea>
            </div>

            <div class="flex justify-end gap-3 pt-4 border-t">
                <button @click="openPoModal = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100">Batal</button>
                <button @click="submitPo()" class="bg-red-600 hover:bg-red-700 text-white px-5 py-2 rounded-xl text-xs font-bold shadow">Kirim PO ke CK</button>
            </div>
        </div>
    </div>

    <!-- ================= MODAL: PROSES / EDIT QTY KIRIM CK ================= -->
    <div x-show="openProcessModalState" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-2xl w-full p-6 shadow-2xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center border-b pb-3">
                <h3 class="font-bold text-lg text-slate-800"><i class="fa-solid fa-list-check text-blue-600 mr-2"></i> Verifikasi & Edit Qty Kirim CK</h3>
                <button @click="openProcessModalState = false" class="text-slate-400 hover:text-slate-600 font-bold">&times;</button>
            </div>
            <p class="text-xs text-slate-500">Sesuaikan jumlah kuantitas bahan baku yang akan dikirim berdasarkan ketersediaan stok riil Central Kitchen.</p>
            
            <div class="space-y-3">
                <template x-for="(item, index) in processingPo.items" :key="index">
                    <div class="bg-slate-50 p-3 rounded-xl border flex flex-col md:flex-row justify-between items-center gap-3">
                        <div class="flex-1">
                            <h4 class="font-bold text-sm text-slate-800" x-text="item.name"></h4>
                            <p class="text-xs text-slate-500">Diminta Resto: <span class="font-semibold" x-text="item.requestedQty + ' ' + item.unit"></span> | Stok CK Ready: <span class="font-semibold text-red-600" x-text="getInventoryStock(item.itemId) + ' ' + item.unit"></span></p>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="text-xs font-semibold text-slate-600">Qty Kirim:</label>
                            <input type="number" min="0" x-model.number="item.qtyKirim" class="w-24 border rounded-lg p-2 text-xs text-center font-bold bg-white">
                            <span class="text-xs font-semibold text-slate-600 w-12" x-text="item.unit"></span>
                        </div>
                    </div>
                </template>
            </div>

            <div class="flex justify-end gap-3 pt-4 border-t">
                <button @click="openProcessModalState = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100">Batal</button>
                <button @click="saveProcessedPo()" class="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2 rounded-xl text-xs font-bold shadow">Simpan & Setujui (Status: Diproses CK)</button>
            </div>
        </div>
    </div>

    <!-- ================= MODAL: SURAT JALAN & DISPATCH ================= -->
    <div x-show="openDispatchModalState" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-xl w-full p-6 shadow-2xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center border-b pb-3">
                <h3 class="font-bold text-lg text-slate-800"><i class="fa-solid fa-truck-fast text-purple-600 mr-2"></i> Penerbitan Surat Jalan & Kirim</h3>
                <button @click="openDispatchModalState = false" class="text-slate-400 hover:text-slate-600 font-bold">&times;</button>
            </div>
            <div class="grid grid-cols-1 gap-3">
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Nama Pengirim (Staf Central Kitchen)</label>
                    <input type="text" x-model="dispatchForm.senderName" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50" placeholder="Nama petugas CK yang menyiapkan...">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Metode Pengiriman</label>
                    <select x-model="dispatchForm.courierType" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50">
                        <option value="Internal Driver">Kurir Internal Resto</option>
                        <option value="Lalamove">Lalamove</option>
                        <option value="GrabExpress">GrabExpress</option>
                        <option value="GoSend">GoSend</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Nama Driver & Plat Nomor Kendaraan</label>
                    <input type="text" x-model="dispatchForm.driverInfo" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50" placeholder="Contoh: Bpk. Budi (B 1234 XYZ)">
                </div>
            </div>
            <div class="flex justify-end gap-3 pt-4 border-t">
                <button @click="openDispatchModalState = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100">Batal</button>
                <button @click="confirmDispatch()" class="bg-purple-600 hover:bg-purple-700 text-white px-5 py-2 rounded-xl text-xs font-bold shadow">Terbitkan Surat Jalan & Potong Stok CK</button>
            </div>
        </div>
    </div>

    <!-- ================= MODAL: TERIMA BARANG OUTLET ================= -->
    <div x-show="openReceiveModalState" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-xl w-full p-6 shadow-2xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center border-b pb-3">
                <h3 class="font-bold text-lg text-slate-800"><i class="fa-solid fa-box-open text-emerald-600 mr-2"></i> Konfirmasi Terima Barang di Outlet</h3>
                <button @click="openReceiveModalState = false" class="text-slate-400 hover:text-slate-600 font-bold">&times;</button>
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-600 mb-1">Nama Penerima (Manager / Staf Outlet Resto)</label>
                <input type="text" x-model="receiveReceiverName" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50" placeholder="Masukkan nama Anda yang menerima fisik barang...">
            </div>
            <div>
                <label class="block text-xs font-semibold text-slate-600 mb-1">Catatan Penerimaan / Selisih / Barang Rusak</label>
                <textarea x-model="receiveDiscrepancyNotes" rows="2" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50" placeholder="Sesuai / ada barang kurang..."></textarea>
            </div>
            <div class="flex justify-end gap-3 pt-4 border-t">
                <button @click="openReceiveModalState = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100">Batal</button>
                <button @click="confirmReceiveGoods()" class="bg-emerald-600 hover:bg-emerald-700 text-white px-5 py-2 rounded-xl text-xs font-bold shadow">Konfirmasi Selesai Diterima</button>
            </div>
        </div>
    </div>

    <!-- ================= MODAL: DETAIL & CETAK SURAT JALAN ================= -->
    <div x-show="openDetailModalState" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-3xl w-full p-6 shadow-2xl space-y-4 max-h-[90vh] overflow-y-auto">
            <div class="flex justify-between items-center border-b pb-3 no-print">
                <h3 class="font-bold text-lg text-slate-800">Detail & Cetak Surat Jalan</h3>
                <div class="space-x-2">
                    <button onclick="window.print()" class="bg-slate-800 hover:bg-slate-900 text-white px-4 py-2 rounded-xl text-xs font-bold"><i class="fa-solid fa-print mr-1"></i> Cetak / PDF</button>
                    <button @click="openDetailModalState = false" class="text-slate-400 hover:text-slate-600 font-bold">&times;</button>
                </div>
            </div>

            <!-- PRINTABLE AREA -->
            <div id="printable-area" class="bg-white p-6 rounded-xl border border-slate-200 space-y-6 text-slate-800">
                <div class="flex justify-between items-start border-b pb-4">
                    <div>
                        <h2 class="text-xl font-black text-red-800">WARUNG SAMBAL SAMUDA NUSANTARA</h2>
                        <p class="text-xs text-slate-500">Central Kitchen & Distribution Center</p>
                    </div>
                    <div class="text-right">
                        <h3 class="font-bold text-lg text-slate-800">SURAT JALAN / PENGIRIMAN</h3>
                        <p class="text-xs font-bold text-red-700" x-text="selectedPo.poNumber"></p>
                        <p class="text-xs text-slate-500" x-text="'Tanggal: ' + selectedPo.targetDate"></p>
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-4 text-xs bg-slate-50 p-4 rounded-xl border">
                    <div>
                        <p class="font-bold text-slate-600 mb-1">TUJUAN OUTLET:</p>
                        <p class="text-sm font-bold text-slate-800" x-text="selectedPo.outletName"></p>
                    </div>
                    <div>
                        <p class="font-bold text-slate-600 mb-1">INFORMASI KURIR & PENGIRIMAN:</p>
                        <p class="text-xs">Kurir: <span class="font-semibold" x-text="selectedPo.courierType || '-'"></span></p>
                        <p class="text-xs">Driver/Plat: <span class="font-semibold" x-text="selectedPo.driverInfo || '-'"></span></p>
                        <p class="text-xs">Pengirim (CK): <span class="font-semibold" x-text="selectedPo.senderName || '-'"></span></p>
                        <p class="text-xs">Penerima (Outlet): <span class="font-semibold" x-text="selectedPo.receiverName || 'Belum Diterima'"></span></p>
                    </div>
                </div>

                <div>
                    <table class="w-full text-left border-collapse text-xs">
                        <thead>
                            <tr class="bg-slate-100 border-b">
                                <th class="p-2.5">No</th>
                                <th class="p-2.5">Nama Bahan Baku</th>
                                <th class="p-2.5 text-center">Qty Diminta</th>
                                <th class="p-2.5 text-center">Qty Dikirim (CK)</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y">
                            <template x-for="(item, index) in selectedPo.items" :key="index">
                                <tr>
                                    <td class="p-2.5" x-text="index + 1"></td>
                                    <td class="p-2.5 font-medium" x-text="item.name"></td>
                                    <td class="p-2.5 text-center" x-text="item.requestedQty + ' ' + item.unit"></td>
                                    <td class="p-2.5 text-center font-bold text-red-700" x-text="(item.qtyKirim !== undefined ? item.qtyKirim : item.qty) + ' ' + item.unit"></td>
                                </tr>
                            </template>
                        </tbody>
                    </table>
                </div>

                <div class="flex justify-between pt-12 text-center text-xs">
                    <div class="space-y-16">
                        <p class="font-semibold">Hormat Kami,<br>Central Kitchen Dispatcher</p>
                        <p class="border-t border-slate-400 pt-1 font-bold" x-text="selectedPo.senderName || '( ........................ )'"></p>
                    </div>
                    <div class="space-y-16">
                        <p class="font-semibold">Ekspedisi / Kurir Driver,</p>
                        <p class="border-t border-slate-400 pt-1 font-bold" x-text="selectedPo.driverInfo || '( ........................ )'"></p>
                    </div>
                    <div class="space-y-16">
                        <p class="font-semibold">Penerima,<br>Outlet Resto Manager</p>
                        <p class="border-t border-slate-400 pt-1 font-bold" x-text="selectedPo.receiverName || '( ........................ )'"></p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ================= MODAL: KELOLA KATEGORI ================= -->
    <div x-show="openCategoryModal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div class="flex justify-between items-center border-b pb-3">
                <h3 class="font-bold text-lg text-slate-800">Manajemen Kategori</h3>
                <button @click="openCategoryModal = false" class="text-slate-400 hover:text-slate-600 font-bold">&times;</button>
            </div>
            <div class="space-y-3">
                <div class="flex gap-2">
                    <input type="text" x-model="newCategoryName" placeholder="Nama kategori baru..." class="flex-1 border rounded-xl p-2.5 text-xs bg-slate-50">
                    <button @click="addCategory()" class="bg-slate-800 text-white px-4 py-2.5 rounded-xl text-xs font-bold">Tambah</button>
                </div>
                <div class="space-y-1 max-h-48 overflow-y-auto">
                    <template x-for="cat in categories" :key="cat">
                        <div class="flex justify-between items-center bg-slate-50 p-2.5 rounded-xl border text-xs">
                            <span class="font-semibold" x-text="cat"></span>
                            <button @click="deleteCategory(cat)" class="text-rose-600 hover:text-rose-800 font-bold">&times;</button>
                        </div>
                    </template>
                </div>
            </div>
        </div>
    </div>

    <!-- ================= MODAL: TAMBAH / EDIT PRODUK SKU ================= -->
    <div x-show="openProductModal" class="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl space-y-4">
            <div class="flex justify-between items-center border-b pb-3">
                <h3 class="font-bold text-lg text-slate-800" x-text="editingProductId ? 'Edit SKU Bahan Baku' : 'Tambah SKU Bahan Baku Baru'"></h3>
                <button @click="openProductModal = false" class="text-slate-400 hover:text-slate-600 font-bold">&times;</button>
            </div>
            <div class="space-y-3">
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Nama Bahan SKU</label>
                    <input type="text" x-model="productForm.name" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50" placeholder="Contoh: Cabe Rawit Merah">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Kategori</label>
                    <select x-model="productForm.category" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50">
                        <option value="">-- Pilih Kategori --</option>
                        <template x-for="cat in categories" :key="cat">
                            <option :value="cat" x-text="cat"></option>
                        </template>
                    </select>
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-semibold text-slate-600 mb-1">Stok Awal / Ready</label>
                        <input type="number" min="0" x-model.number="productForm.stock" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50">
                    </div>
                    <div>
                        <label class="block text-xs font-semibold text-slate-600 mb-1">Satuan</label>
                        <select x-model="productForm.unit" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50">
                            <option value="Kg">Kg</option>
                            <option value="Pcs">Pcs</option>
                            <option value="Liter">Liter</option>
                            <option value="Pack">Pack</option>
                            <option value="Box">Box</option>
                        </select>
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-slate-600 mb-1">Batas Buffer Stok Minimum</label>
                    <input type="number" min="0" x-model.number="productForm.minBuffer" class="w-full border rounded-xl p-2.5 text-sm bg-slate-50">
                </div>
            </div>
            <div class="flex justify-end gap-3 pt-4 border-t">
                <button @click="openProductModal = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:bg-slate-100">Batal</button>
                <button @click="saveProduct()" class="bg-red-600 hover:bg-red-700 text-white px-5 py-2 rounded-xl text-xs font-bold shadow">Simpan Produk</button>
            </div>
        </div>
    </div>

    <!-- ================= ALPINE.JS APPLICATION LOGIC ================= -->
    <script>
        document.addEventListener('alpine:init', () => {
            Alpine.data('scmApp', () => ({
                currentRole: 'resto',
                activeCkTab: 'po',
                roles: [
                    { id: 'resto', name: 'Outlet Resto' },
                    { id: 'ck', name: 'Central Kitchen' },
                    { id: 'audit', name: 'Audit & Laporan' }
                ],
                notification: { show: false, message: '', type: 'success' },

                inventory: [],
                categories: ['Bumbu & Sambal', 'Daging & Ayam', 'Sayuran Segar', 'Kemasan & Plastik'],
                poList: [],
                stockLogs: [],

                openPoModal: false,
                openProcessModalState: false,
                openDispatchModalState: false,
                openReceiveModalState: false,
                openDetailModalState: false,
                openCategoryModal: false,
                openProductModal: false,

                newPo: {
                    outletName: 'Resto Samuda Pusat',
                    targetDate: new Date().toISOString().split('T')[0],
                    notes: '',
                    items: [{ itemId: '', qty: 1, unit: 'Kg' }]
                },
                processingPo: { items: [] },
                dispatchForm: { senderName: '', courierType: 'Internal Driver', driverInfo: '' },
                receiveReceiverName: '',
                receiveDiscrepancyNotes: '',
                selectedPo: { items: [] },

                newCategoryName: '',
                editingProductId: null,
                productForm: { name: '', category: '', stock: 0, unit: 'Kg', minBuffer: 5 },

                init() {
                    window.addEventListener('firebase-ready', () => {
                        this.fetchFirebaseData();
                    });
                },

                showNotification(msg, type = 'success') {
                    this.notification = { show: true, message: msg, type: type };
                    setTimeout(() => { this.notification.show = false; }, 4000);
                },

                fetchFirebaseData() {
                    const { collection, onSnapshot } = window.firebaseModules;
                    const db = window.db;

                    onSnapshot(collection(db, 'inventory'), (snapshot) => {
                        this.inventory = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
                    });

                    onSnapshot(collection(db, 'purchase_orders'), (snapshot) => {
                        this.poList = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
                    });

                    onSnapshot(collection(db, 'stock_logs'), (snapshot) => {
                        this.stockLogs = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
                    });

                    onSnapshot(collection(db, 'categories'), (snapshot) => {
                        if (!snapshot.empty) {
                            this.categories = snapshot.docs.map(doc => doc.data().name);
                        }
                    });
                },

                updateItemUnit(index) {
                    const selectedId = this.newPo.items[index].itemId;
                    const found = this.inventory.find(i => i.id === selectedId);
                    if (found) {
                        this.newPo.items[index].unit = found.unit;
                    }
                },

                getInventoryStock(itemId) {
                    const found = this.inventory.find(i => i.id === itemId);
                    return found ? found.stock : 0;
                },

                async submitPo() {
                    if (!this.newPo.outletName || this.newPo.items.length === 0) {
                        this.showNotification('Lengkapi data PO dengan benar!', 'error');
                        return;
                    }
                    const { collection, addDoc } = window.firebaseModules;
                    const db = window.db;

                    const poData = {
                        poNumber: 'PO-' + Math.floor(100000 + Math.random() * 900000),
                        outletName: this.newPo.outletName,
                        targetDate: this.newPo.targetDate,
                        notes: this.newPo.notes,
                        status: 'Pending',
                        items: this.newPo.items.map(i => {
                            const inv = this.inventory.find(x => x.id === i.itemId);
                            return {
                                itemId: i.itemId,
                                name: inv ? inv.name : 'Unknown',
                                requestedQty: i.qty,
                                qtyKirim: i.qty,
                                unit: i.unit
                            };
                        }),
                        createdAt: new Date().toLocaleString()
                    };

                    await addDoc(collection(db, 'purchase_orders'), poData);
                    this.openPoModal = false;
                    this.newPo.items = [{ itemId: '', qty: 1, unit: 'Kg' }];
                    this.showNotification('Purchase Order berhasil dikirim ke Central Kitchen!');
                },

                openProcessModal(po) {
                    this.processingPo = JSON.parse(JSON.stringify(po));
                    this.openProcessModalState = true;
                },

                async saveProcessedPo() {
                    const { doc, updateDoc } = window.firebaseModules;
                    const db = window.db;

                    const poRef = doc(db, 'purchase_orders', this.processingPo.id);
                    await updateDoc(poRef, {
                        status: 'Diproses CK',
                        items: this.processingPo.items
                    });

                    this.openProcessModalState = false;
                    this.showNotification('PO berhasil diverifikasi dan siap dikirim!');
                },

                openDispatchModal(po) {
                    this.selectedPo = po;
                    this.dispatchForm = { senderName: '', courierType: 'Internal Driver', driverInfo: '' };
                    this.openDispatchModalState = true;
                },

                async confirmDispatch() {
                    if (!this.dispatchForm.senderName || !this.dispatchForm.driverInfo) {
                        this.showNotification('Harap isi Nama Pengirim dan Info Kurir!', 'error');
                        return;
                    }

                    const { doc, updateDoc, collection, addDoc } = window.firebaseModules;
                    const db = window.db;

                    const poRef = doc(db, 'purchase_orders', this.selectedPo.id);
                    await updateDoc(poRef, {
                        status: 'Dikirim',
                        senderName: this.dispatchForm.senderName,
                        courierType: this.dispatchForm.courierType,
                        driverInfo: this.dispatchForm.driverInfo
                    });

                    for (let item of this.selectedPo.items) {
                        const qtyKirim = item.qtyKirim !== undefined ? item.qtyKirim : item.requestedQty;
                        const invItem = this.inventory.find(x => x.id === item.itemId);
                        if (invItem) {
                            const newStock = Math.max(0, invItem.stock - qtyKirim);
                            await updateDoc(doc(db, 'inventory', invItem.id), { stock: newStock });

                            await addDoc(collection(db, 'stock_logs'), {
                                timestamp: new Date().toLocaleString(),
                                type: 'KELUAR',
                                itemName: invItem.name,
                                qty: qtyKirim,
                                unit: invItem.unit,
                                notes: `Pengiriman PO ${this.selectedPo.poNumber} ke ${this.selectedPo.outletName}`
                            });
                        }
                    }

                    this.openDispatchModalState = false;
                    this.showNotification('Surat Jalan diterbitkan dan stok CK berhasil dipotong!');
                },

                openReceiveModal(po) {
                    this.selectedPo = po;
                    this.receiveReceiverName = '';
                    this.receiveDiscrepancyNotes = '';
                    this.openReceiveModalState = true;
                },

                async confirmReceiveGoods() {
                    if (!this.receiveReceiverName) {
                        this.showNotification('Nama penerima wajib diisi!', 'error');
                        return;
                    }
                    const { doc, updateDoc } = window.firebaseModules;
                    const db = window.db;

                    const poRef = doc(db, 'purchase_orders', this.selectedPo.id);
                    await updateDoc(poRef, {
                        status: 'Diterima Outlet',
                        receiverName: this.receiveReceiverName,
                        discrepancyNotes: this.receiveDiscrepancyNotes
                    });

                    this.openReceiveModalState = false;
                    this.showNotification('Barang telah dikonfirmasi diterima di outlet!');
                },

                viewPoDetail(po) {
                    this.selectedPo = po;
                    this.openDetailModalState = true;
                },

                async addCategory() {
                    if (!this.newCategoryName) return;
                    const { collection, addDoc } = window.firebaseModules;
                    const db = window.db;
                    await addDoc(collection(db, 'categories'), { name: this.newCategoryName });
                    this.newCategoryName = '';
                    this.showNotification('Kategori baru berhasil ditambahkan!');
                },

                async deleteCategory(catName) {
                    this.categories = this.categories.filter(c => c !== catName);
                    this.showNotification('Kategori dihapus.');
                },

                editProduct(item) {
                    this.editingProductId = item.id;
                    this.productForm = { name: item.name, category: item.category, stock: item.stock, unit: item.unit, minBuffer: item.minBuffer };
                    this.openProductModal = true;
                },

                async saveProduct() {
                    const { collection, addDoc, doc, updateDoc } = window.firebaseModules;
                    const db = window.db;

                    if (this.editingProductId) {
                        await updateDoc(doc(db, 'inventory', this.editingProductId), this.productForm);
                        this.showNotification('Produk SKU berhasil diperbarui!');
                    } else {
                        await addDoc(collection(db, 'inventory'), this.productForm);
                        this.showNotification('Produk SKU baru berhasil ditambahkan!');
                    }
                    this.openProductModal = false;
                    this.editingProductId = null;
                    this.productForm = { name: '', category: '', stock: 0, unit: 'Kg', minBuffer: 5 };
                },

                async deleteProduct(id) {
                    if (confirm('Yakin ingin menghapus produk ini?')) {
                        const { doc, deleteDoc } = window.firebaseModules;
                        const db = window.db;
                        await deleteDoc(doc(db, 'inventory', id));
                        this.showNotification('Produk berhasil dihapus.');
                    }
                }
            }));
        });
    </script>
</body>
</html>
