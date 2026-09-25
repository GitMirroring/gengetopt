/* test_groups.c test */

/* test all kinds of options */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <stdlib.h>
#include <stdio.h>

#include "test_groups_flags_cmd.h"

static struct gengetopt_args_info args_info;

int
main (int argc, char **argv)
{
  if (test_groups_flags_cmd_parser (argc, argv, &args_info) != 0)
    exit(1) ;

  if (args_info.dumb_given)
    {
      printf("Flag dumb was given\n");
      printf("dumb flag: %d\n", args_info.dumb_flag);
    }
  printf("dumb flag: %d\n", args_info.dumb_flag);

  if (args_info.extended_given)
    {
      printf("Flag extended was given\n");
    }
  printf("extended flag: %d\n", args_info.extended_flag);

  test_groups_flags_cmd_parser_free (&args_info);

  return 0;
}
