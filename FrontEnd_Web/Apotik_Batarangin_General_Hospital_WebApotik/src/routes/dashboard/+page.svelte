<script lang="ts">
    import { onMount } from 'svelte';
    import type { ChartData } from './+page.server';
  
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Aug', 'Sept', 'Okt', 'Nov', 'Des'];
    let customerData: ChartData[] = [];
  
    onMount(() => {
      // Initialize chart data
      customerData = months.map((_, i) => ({
        month: i + 1,
        value: Math.floor(Math.random() * 20)
      }));
    });

    // Helper function to get month name
    const getMonthName = (monthNum: number) => months[monthNum - 1];
</script>

<main class="flex flex-col w-full p-6">
    <div class="flex flex-col w-full gap-6">
      <div class="w-full">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-5 border">
          <section class="w-full" aria-labelledby="customer-chart-title">
            <div class="flex flex-col p-6 bg-white rounded-lg shadow-sm h-full">
              <h2 id="customer-chart-title" class="text-lg font-medium text-black mb-4">Jumlah Customer</h2>
              
              <!-- Customer Chart Component -->
              <div class="relative w-full h-[400px] mt-8 border-2" role="img" aria-label="Customer growth chart showing monthly data">
                <!-- Y-axis labels -->
                <div class="absolute left-3 h-full flex flex-col justify-between text-sm text-center text-gray-600" style="transform: translateY(0);">
                  {#each Array(5) as _, i}
                    <span>{20 - i * 5}</span>
                  {/each}
                  <span class="translate-y-[-10px]">0</span>
                </div>

                <!-- Chart bars -->
                <div class="absolute left-12 right-3 h-full flex items-end justify-between">
                  {#each customerData as data}
                    <div class="flex flex-col items-center gap-2 w-16">
                      <div class="w-12 bg-red-200" style="height: {data.value * 15}px;" />
                      <span class="text-sm text-gray-600">{getMonthName(data.month)}</span>
                    </div>
                  {/each}
                </div>
              </div>
            </div>
          </section>

          <section class="w-full" aria-labelledby="product-chart-title">
            <div class="flex flex-col p-6 bg-white rounded-lg shadow-sm h-full">
              <h2 id="product-chart-title" class="text-lg font-medium text-black mb-4">Distribusi Produk</h2>
              <div class="flex flex-wrap gap-4">
                <img loading="lazy" src="https://cdn.builder.io/api/v1/image/assets/TEMP/84660f07d7d726af5d68d0c229eb216bff7d6f75d57dee5e9ac6166481f2d863?placeholderIfAbsent=true&apiKey=7899b3ebb52b421690fdee92b9703ba7" class="object-contain w-full max-w-[400px] mx-auto" alt="Product distribution pie chart" />
                
                <div class="flex flex-col justify-center items-start gap-2" role="list" aria-label="Product legend">
                  {#each ['Paracetamol', 'Lelap', 'Promag', 'Decolsin', 'Neozep'] as product, i}
                    <div class="flex items-center gap-2 p-2" role="listitem">
                      <img loading="lazy" src={`http://b.io/ext_${11 + i}-`} class="w-5 h-5" alt="" />
                      <span class="text-sm">{product}</span>
                    </div>
                  {/each}
                </div>
              </div>
            </div>
          </section>
        </div>
      </div>

      <section class="w-full" aria-labelledby="transactions-chart-title">
        <div class="flex flex-col p-6 bg-white rounded-lg shadow-sm">
          <h2 id="transactions-chart-title" class="text-lg font-medium text-black mb-4">Overview Transaksi</h2>
          <img loading="lazy" src="https://cdn.builder.io/api/v1/image/assets/TEMP/6a3f6b8be2b4efbc5e129926f9334189b4455bd1c8294a7b7f35e58ae29f5b5d?placeholderIfAbsent=true&apiKey=7899b3ebb52b421690fdee92b9703ba7" class="w-full h-auto object-contain mb-4" alt="Transactions trend chart" />
          
          <div class="flex flex-wrap justify-center gap-4">
            <div class="flex items-center gap-2 p-2">
              <img loading="lazy" src="https://cdn.builder.io/api/v1/image/assets/TEMP/c5b25ef888e9b5dca2964e97441d3b89b9c6b076b9189f78a547c20431d775ab?placeholderIfAbsent=true&apiKey=7899b3ebb52b421690fdee92b9703ba7" class="w-5 h-5" alt="" />
              <span class="text-sm">Request Barang</span>
            </div>
            <div class="flex items-center gap-2 p-2">
              <img loading="lazy" src="https://cdn.builder.io/api/v1/image/assets/TEMP/1deae766c01ae5cb7d62e961b3553ca639be48c513268ef99f242d59b386634d?placeholderIfAbsent=true&apiKey=7899b3ebb52b421690fdee92b9703ba7" class="w-5 h-5" alt="" />
              <span class="text-sm">Return Barang</span>
            </div>
          </div>
        </div>
      </section>
    </div>
  </main>