#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#define BUFF_SIZE 100
#define TO_DESTROY 200
typedef struct int_pair {
	int a;
	int b;
} int_pair;

typedef struct int_pair_cont {
	int_pair* pairs;
	int size;
} int_pair_cont;

void generate_coprimes_rec(int_pair_cont* pairs, int c_x, int c_y, int e_x, int e_y)
{
	if ((c_x < e_x) && (c_y < e_y))
	{
		pairs->pairs[pairs->size].a = c_x;
		pairs->pairs[pairs->size].b = c_y;
		pairs->size++;
		generate_coprimes_rec(pairs, 2 * c_x - c_y, c_x, e_x, e_y);
		generate_coprimes_rec(pairs, 2 * c_x + c_y, c_x, e_x, e_y);
		generate_coprimes_rec(pairs, c_x + 2 * c_y, c_y, e_x, e_y);
	}
}

int coprime_tan_comparator(const void* x, const void* y)
{
	int_pair* px = x;
	int_pair* py = y;
	if (atan2l((long double)(px->a), (long double)(px->b)) < atan2l((long double)(py->a), (long double)(py->b)))
		return 1;
	else return -1;
}


int_pair_cont* generate_coprimes(int x, int y)
{
	
	int_pair_cont* container = malloc(sizeof(int_pair_cont));
	int size = 2 + (x*y) / 2; //Generous estimation.
	container->size = 0;
	int_pair* pairs = malloc(sizeof(int_pair) * size);
	container->pairs = pairs + 1;
	generate_coprimes_rec(container, 2, 1, x, y);
	generate_coprimes_rec(container, 3, 1, x, y);
	qsort(container->pairs, container->size, sizeof(int_pair), *coprime_tan_comparator);
	container->pairs = pairs;
	container->pairs[0].a = 1;
	container->pairs[0].b = 0;
	container->pairs[container->size+1].a = 1;
	container->pairs[container->size+1].b = 1;
	container->size += 2;
	return container;


}



int search_line(char** map, int a, int b, int i, int j, int size_x, int size_y)
{
	for (int k = 1;; k++)
	{
		if (i + k * a >= size_y) return 0;
		if (j + k * b >= size_x) return 0;
		if (i + k * a < 0) return 0;
		if (j + k * b < 0) return 0;
		if (map[i + k * a][j + k * b] == '#')
		{
			return 1;
		}
	}
}

int destroy_line(char** map, int a, int b, int i, int j, int size_x, int size_y)
{
	for (int k = 1;; k++)
	{
		if (i + k * a >= size_y) return 0;
		if (j + k * b >= size_x) return 0;
		if (i + k * a < 0) return 0;
		if (j + k * b < 0) return 0;
		if (map[i + k * a][j + k * b] == '#')
		{
			map[i + k * a][j + k * b] = ".";
			return (i + k * a) + (j + k * b) * 100;
		}
	}
}

int search_all_lines(char** map, int a, int b, int i, int j, int size_x, int size_y)
{
	if (b != 0 && a != b)
		return
		search_line(map, a, b, i, j, size_x, size_y) +
		search_line(map, b, a, i, j, size_x, size_y) +
		search_line(map, -a, b, i, j, size_x, size_y) +
		search_line(map, b, -a, i, j, size_x, size_y) +
		search_line(map, a, -b, i, j, size_x, size_y) +
		search_line(map, -b, a, i, j, size_x, size_y) +
		search_line(map, -a, -b, i, j, size_x, size_y) +
		search_line(map, -b, -a, i, j, size_x, size_y);
	else
		return
		search_line(map, a, b, i, j, size_x, size_y) +
		search_line(map, b, a, i, j, size_x, size_y) +
		search_line(map, -a, b, i, j, size_x, size_y) +
		search_line(map, b, -a, i, j, size_x, size_y);
}

int main()
{
	FILE *in_f;
	char buff[BUFF_SIZE];
	fopen_s(&in_f,"Day 10.txt", "rt");
	int size_x = 0;
	while (fgets(buff, BUFF_SIZE, in_f) != NULL)
	{
		for (int i = 0; i < BUFF_SIZE; i++)
		{
			if (buff[i] == 0x0A)
			{
				size_x += i;
				goto endloop; //yes, super evil, I know.
			}
		}
		size_x += BUFF_SIZE;
	}
endloop:
	fseek(in_f, 0L, SEEK_END);
	int size_y = ftell(in_f) / (size_x + 1);
	rewind(in_f);
	char** map = malloc(sizeof(char*)*size_y);
	for (int i = 0; i < size_y; i++)
	{
		map[i] = malloc(sizeof(char)*(size_x));
		fread(map[i], size_x, 1, in_f);
		fgetc(in_f);
	}
	int_pair_cont* coprimes = generate_coprimes(size_x, size_y);

	int max = 0;
	int max_x = 0;
	int max_y = 0;

	for (int i = 0; i < size_y; i++)
	{
		for (int j = 0; j < size_x; j++)
		{
			int curr = 0;
			if (map[i][j] != '#') continue;
			for (int p = 0; p < coprimes->size; p++)
			{
				curr += search_all_lines(map, coprimes->pairs[p].a, coprimes->pairs[p].b, i, j, size_x, size_y);
			}
			if (max < curr)
			{
				max = curr;
				max_x = j;
				max_y = i;

			}
		}
	}
	printf_s("%d\n", max);
	int dest_v = 0;
	int destroyed = 0;
	while (destroyed < TO_DESTROY)
	{
		for (int p = 0; p < coprimes->size-1; p++)
		{
			dest_v = destroy_line(map, -coprimes->pairs[p].a, coprimes->pairs[p].b, max_y, max_x, size_x, size_y);
			if (dest_v != 0) destroyed++;
			if (destroyed == TO_DESTROY)
			{
				goto endloop2;
			}
		}

		for (int p = coprimes->size - 1; p > 0; p--)
		{
			dest_v = destroy_line(map, -coprimes->pairs[p].b, coprimes->pairs[p].a, max_y, max_x, size_x, size_y);
			if (dest_v != 0) destroyed++;
			if (destroyed == TO_DESTROY)
			{
				goto endloop2;
			}
		}

		for (int p = 0; p < coprimes->size-1; p++)
		{
			dest_v = destroy_line(map, coprimes->pairs[p].b, coprimes->pairs[p].a, max_y, max_x, size_x, size_y);
			if (dest_v != 0) destroyed++;
			if (destroyed == TO_DESTROY)
			{
				goto endloop2;
			}
		}

		for (int p = coprimes->size - 1; p > 0; p--)
		{
			dest_v = destroy_line(map, coprimes->pairs[p].a, coprimes->pairs[p].b, max_y, max_x, size_x, size_y);
			if (dest_v != 0) destroyed++;
			if (destroyed == TO_DESTROY)
			{
				goto endloop2;
			}
		}

		for (int p = 0; p < coprimes->size-1; p++)
		{
			dest_v = destroy_line(map, coprimes->pairs[p].a, -coprimes->pairs[p].b, max_y, max_x, size_x, size_y);
			if (dest_v != 0) destroyed++;
			if (destroyed == TO_DESTROY)
			{
				goto endloop2;
			}
		}

		for (int p = coprimes->size - 1; p > 0; p--)
		{
			dest_v = destroy_line(map, coprimes->pairs[p].b, -coprimes->pairs[p].a, max_y, max_x, size_x, size_y);
			if (dest_v != 0) destroyed++;
			if (destroyed == TO_DESTROY)
			{
				goto endloop2;
			}
		}

		for (int p = 0; p < coprimes->size-1; p++)
		{
			dest_v = destroy_line(map, -coprimes->pairs[p].b, -coprimes->pairs[p].a, max_y, max_x, size_x, size_y);
			if (dest_v != 0) destroyed++;
			if (destroyed == TO_DESTROY)
			{
				goto endloop2;
			}
		}

		for (int p = coprimes->size - 1; p > 0; p--)
		{
			dest_v = destroy_line(map, -coprimes->pairs[p].a, -coprimes->pairs[p].b, max_y, max_x, size_x, size_y);
			if (dest_v != 0) destroyed++;
			if (destroyed == TO_DESTROY)
			{
				goto endloop2;
			}
		}
	}
endloop2:
	printf("%d\n", dest_v);

	fclose(in_f);
	return 0;
}