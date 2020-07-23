#include <stdbool.h>

#include <scheme.h>

#define MAX(x, y) (((x) > (y)) ? (x) : (y))
#define MIN(x, y) (((x) < (y)) ? (x) : (y))
#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))
#define FLAT_INDEX(i, j, w) (j) * (w) + (i)

ptr Shamming(ptr str1, ptr str2)
{
    iptr distance = 0;
    iptr len = Sstring_length(str1);

    if (len != Sstring_length(str2))
    {
        return Sfixnum(distance);
    }

    for (iptr i = 0; i < len; i++)
    {
        if (Sstring_ref(str1, i) != Sstring_ref(str2, i))
        {
            distance += (iptr)1;
        }
    }

    return Sfixnum(distance);
}

ptr Slevenshtein(ptr str1, ptr str2)
{
    iptr m = Sstring_length(str1);
    iptr n = Sstring_length(str2);
    iptr i, j, lastdiag, olddiag;
    iptr column[m + 1];

    for (i = 0; i <= m; i++)
    {
        column[i] = i;
    }
    for (j = 1; j <= n; j++)
    {
        olddiag = column[0];
        column[0] += 1;

        for (i = 1; i <= m; i++)
        {
            lastdiag = column[i];
            if (Sstring_ref(str1, i - 1) == Sstring_ref(str2, j - 1))
            {
                column[i] = olddiag;
            }
            else
            {
                column[i] = 1 + MIN3(column[i - 1], column[i], olddiag);
            }
            olddiag = lastdiag;
        }
    }

    return Sinteger64(column[m]);
}

ptr Snorm_levenshtein(ptr str1, ptr str2)
{
    iptr r = Sinteger64_value(Slevenshtein(str1, str2));
    if (r == 0)
    {
        return Sflonum(1.0);
    }

    iptr len1 = Sstring_length(str1);
    iptr len2 = Sstring_length(str2);
    iptr longer_len = MAX(len1, len2);
    return Sflonum(1.0 - (double)r / (double)longer_len);
}

ptr Sdamerau_levenshtein(ptr str1, ptr str2)
{
    iptr len1 = Sstring_length(str1);
    iptr len2 = Sstring_length(str2);
    if (len1 == 0)
        return Sinteger64(len2);
    if (len2 == 0)
        return Sinteger64(len1);

    iptr n = len1 + 1;
    iptr m = len2 + 1;
    iptr i, j, cost;
    iptr matrix[n][m];

    for (i = 0; i < n; i++)
    {
        matrix[i][0] = i;
    }
    for (j = 0; j < m; j++)
    {
        matrix[0][j] = j;
    }

    for (i = 1; i < n; i++)
    {
        for (j = 1; j < m; j++)
        {
            cost = Sstring_ref(str1, i - 1) == Sstring_ref(str2, j - 1) ? 0 : 1;
            matrix[i][j] = MIN3(
                matrix[i - 1][j] + 1,       // delete
                matrix[i][j - 1] + 1,       // insert
                matrix[i - 1][j - 1] + cost // replace
            );

            if (i > 1 && j > 1 && Sstring_ref(str1, i - 1) == Sstring_ref(str2, j - 2) && Sstring_ref(str1, i - 2) == Sstring_ref(str2, j - 1))
            {
                matrix[i][j] = MIN(matrix[i][j], cost + matrix[i - 2][j - 2]);
            }
        }
    }

    return Sinteger64(matrix[n - 1][m - 1]);
}

ptr Snorm_damerau_levenshtein(ptr str1, ptr str2)
{
    iptr r = Sinteger64_value(Sdamerau_levenshtein(str1, str2));
    if (r == 0)
    {
        return Sflonum(1.0);
    }

    iptr len1 = Sstring_length(str1);
    iptr len2 = Sstring_length(str2);
    iptr longer_len = MAX(len1, len2);
    return Sflonum(1.0 - (double)r / (double)longer_len);
}

ptr Sjaro(ptr str1, ptr str2)
{
    iptr len1 = Sstring_length(str1);
    iptr len2 = Sstring_length(str2);

    if (len1 == 0 && len2 == 0)
        return Sflonum(1.0);

    iptr match_distance = (len1 > len2 ? len1 : len2) / 2 - 1;
    bool s1_matches[len1], s2_matches[len2];
    iptr m = 0;
    iptr i, j, start, end;

    for (i = 0; i < len1; i++)
        s1_matches[i] = false;
    for (i = 0; i < len2; i++)
        s2_matches[i] = false;

    for (i = 0; i < len1; i++)
    {
        start = MAX(0, i - match_distance);
        end = MIN(i + match_distance + 1, len2);
        for (j = start; j < end; j++)
        {
            if (s2_matches[j] == false && Sstring_ref(str1, i) == Sstring_ref(str2, j))
            {
                s1_matches[i] = true;
                s2_matches[j] = true;
                m += 1;
                break;
            }
        }
    }
    if (m == 0)
        return Sflonum(0.0);

    double t = 0.0;
    iptr k = 0;
    for (i = 0; i < len1; i++)
    {
        if (s1_matches[i] == true)
        {
            while (s2_matches[k] == false)
                k += 1;
            if (Sstring_ref(str1, i) != Sstring_ref(str2, k))
                t += 0.5;
            k += 1;
        }
    }
    double fm = (double)m;
    return Sflonum((fm / (double)len1 + fm / (double)len2 + (fm - t) / fm) / 3.0);
}

inline iptr common_prefix_length(ptr str1, ptr str2)
{
    iptr len1 = Sstring_length(str1);
    iptr len2 = Sstring_length(str2);

    iptr len = MIN(len1, len2);
    for (iptr i = 0; i < len; i++)
    {
        if (Sstring_ref(str1, i) != Sstring_ref(str2, i))
        {
            return i;
        }
    }
    return len;
}

ptr Sjaro_winkler(ptr str1, ptr str2)
{
    double jd = Sflonum_value(Sjaro(str1, str2));
    iptr l = common_prefix_length(str1, str2);
    return Sflonum(jd + l * 0.1 * (1.0 - jd));
}
