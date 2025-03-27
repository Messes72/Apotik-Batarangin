<script>
    let items = [
      { id: 1, text: "Item 1" },
      { id: 2, text: "Item 2" },
      { id: 3, text: "Item 3" },
      { id: 4, text: "Item 4" },
      { id: 5, text: "Item 5" }
    ];
    
    let page = 1;
    const perPage = 3;
    let newItem = "";
  
    function addItem() {
      if (newItem.trim() === "") return;
  
      // Insert new item at the beginning
      items = [{ id: Date.now(), text: newItem }, ...items];
      newItem = "";
  
      // Reset to the first page
      page = 1;
    }
  
    function paginatedItems() {
      const start = (page - 1) * perPage;
      return items.slice(start, start + perPage);
    }
  
    function nextPage() {
      if (page < Math.ceil(items.length / perPage)) {
        page++;
      }
    }
  
    function prevPage() {
      if (page > 1) {
        page--;
      }
    }
  </script>
  
  <input bind:value={newItem} placeholder="Enter new item" />
  <button on:click={addItem}>Add Item</button>
  
  <ul>
    {#each paginatedItems() as item}
      <li>{item.text}</li>
    {/each}
  </ul>
  
  <button on:click={prevPage} disabled={page === 1}>Previous</button>
  <button on:click={nextPage} disabled={page >= Math.ceil(items.length / perPage)}>Next</button>
  
  <p>Page {page} of {Math.ceil(items.length / perPage)}</p>
  