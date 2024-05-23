require 'json'
class App
  # You can change the parameters to the initializer if you like
  def initialize
    @data = [] # Initialize an empty array to hold data from JSON files
  end

  # Method to load JSON data from files into the @data array
  def load_data
    (1..2).each do |page_number|
      file_path = "files/pages/#{page_number}.json"
      @data << JSON.parse(File.read(file_path))
    end
  end

  # Method to extract tables from the loaded data
  def extract_tables
    tables = []
    @data.each do |page| # Iterate over each page of data
      page.each do |block| # Iterate over each block in the page
        if block["BlockType"] == "TABLE"
          tables << extract_table(block)
        end
      end
    end
    tables
  end

  # Method to extract the content of a table block
  def extract_table(table_block)
    table = []
    cell_blocks = table_block["Children"].map { |id| find_block_by_id(id) } # Find all cell blocks in the table
    cells = cell_blocks.select { |block| block["BlockType"] == "CELL" } # Filter to only include cell blocks

    # Group cells by their row index and sort them by their column index within each row
    cells.group_by { |cell| cell["CellLocation"]["R"] }.each do |row_index, row_cells|
      row = row_cells.sort_by { |cell| cell["CellLocation"]["C"] }.map { |cell| extract_text_from_cell(cell) } # Extract text from each cell
      table << row
    end

    table
  end

  # Method to extract text from a cell block
  def extract_text_from_cell(cell_block)
    word_blocks = cell_block["Children"].map { |id| find_block_by_id(id) } # Find all word blocks in the cell
    words = word_blocks.select { |block| block["BlockType"] == "WORD" }
    words.map { |word| word["Text"] }.join(" ") # Extract the text from each word block and join them with spaces
  end

  # Method to find a block by its ID
  def find_block_by_id(id)
    @data.each do |page|
      page.each do |block|
        return block if block["Id"] == id
      end
    end
    nil
  end

  # Method to run the complete script
  def run_script
    load_data
    tables = extract_tables
    print_tables(tables)
  end

  # Method to print the extracted tables
  def print_tables(tables)
    tables.each do |table|
      table.each do |row|
        puts row.join(" | ") # Print the row, joining cell contents with " | "
      end
      puts "-" * 50 # Print a separator line between tables
    end
  end
end
