package utils;

/**
 * Utility class for pagination operations
 */
public class PaginationUtil {

    private int currentPage;
    private int pageSize;
    private int totalRecords;
    private int totalPages;

    /**
     * Constructor for pagination
     * 
     * @param currentPage  Current page number (1-indexed)
     * @param pageSize     Number of records per page
     * @param totalRecords Total number of records
     */
    public PaginationUtil(int currentPage, int pageSize, int totalRecords) {
        this.currentPage = Math.max(1, currentPage);
        this.pageSize = pageSize > 0 ? pageSize : 10;
        this.totalRecords = Math.max(0, totalRecords);
        this.totalPages = (int) Math.ceil((double) this.totalRecords / this.pageSize);

        if (this.currentPage > this.totalPages && this.totalPages > 0) {
            this.currentPage = this.totalPages;
        }
    }

    public int getCurrentPage() {
        return currentPage;
    }

    public int getPageSize() {
        return pageSize;
    }

    public int getTotalRecords() {
        return totalRecords;
    }

    public int getTotalPages() {
        return totalPages;
    }

    public int getStartIndex() {
        return (currentPage - 1) * pageSize;
    }

    public int getEndIndex() {
        return Math.min(getStartIndex() + pageSize, totalRecords);
    }

    public boolean hasPreviousPage() {
        return currentPage > 1;
    }

    public boolean hasNextPage() {
        return currentPage < totalPages;
    }

    public int getPreviousPage() {
        return Math.max(1, currentPage - 1);
    }

    public int getNextPage() {
        return Math.min(totalPages, currentPage + 1);
    }

    public Integer[] getPageNumbers(int maxPages) {
        if (totalPages <= maxPages) {
            Integer[] pages = new Integer[totalPages];
            for (int i = 0; i < totalPages; i++) {
                pages[i] = i + 1;
            }
            return pages;
        }

        Integer[] pages = new Integer[maxPages];
        int startPage = Math.max(1, currentPage - maxPages / 2);
        int endPage = Math.min(totalPages, startPage + maxPages - 1);

        if (endPage - startPage + 1 < maxPages) {
            startPage = Math.max(1, endPage - maxPages + 1);
        }

        for (int i = 0; i < maxPages; i++) {
            if (startPage + i <= endPage) {
                pages[i] = startPage + i;
            }
        }

        return pages;
    }

    public int getOffset() {
        return getStartIndex();
    }

    public int getLimit() {
        return pageSize;
    }

    public String getInfo() {
        if (totalRecords == 0) {
            return "No records found";
        }

        return String.format("Page %d of %d (%d-%d of %d records)",
                currentPage, totalPages, getStartIndex() + 1, getEndIndex(), totalRecords);
    }

    public boolean isValid() {
        return currentPage >= 1 && currentPage <= totalPages;
    }

    public String buildPageUrl(String baseUrl, int pageNumber) {
        String separator = baseUrl.contains("?") ? "&" : "?";
        return baseUrl + separator + "page=" + pageNumber;
    }

    public String getHtmlPagination(String baseUrl) {
        StringBuilder html = new StringBuilder();
        html.append("<nav aria-label='Page navigation'><ul class='pagination'>");

        if (hasPreviousPage()) {
            html.append(String.format("<li class='page-item'><a class='page-link' href='%s'>Previous</a></li>",
                    buildPageUrl(baseUrl, getPreviousPage())));
        } else {
            html.append("<li class='page-item disabled'><span class='page-link'>Previous</span></li>");
        }

        Integer[] pageNumbers = getPageNumbers(5);
        for (Integer pageNum : pageNumbers) {
            if (pageNum == null)
                continue;
            if (pageNum == currentPage) {
                html.append(
                        String.format("<li class='page-item active'><span class='page-link'>%d</span></li>", pageNum));
            } else {
                html.append(String.format("<li class='page-item'><a class='page-link' href='%s'>%d</a></li>",
                        buildPageUrl(baseUrl, pageNum), pageNum));
            }
        }

        if (hasNextPage()) {
            html.append(String.format("<li class='page-item'><a class='page-link' href='%s'>Next</a></li>",
                    buildPageUrl(baseUrl, getNextPage())));
        } else {
            html.append("<li class='page-item disabled'><span class='page-link'>Next</span></li>");
        }

        html.append("</ul></nav>");
        return html.toString();
    }
}
